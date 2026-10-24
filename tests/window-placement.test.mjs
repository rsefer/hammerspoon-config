import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
import test from 'node:test';

const require = createRequire(import.meta.url);
const { default: SDCWindows } = require('../compiled/lib/SDCWindows.js');
const { sizes } = require('../compiled/lib/window-sizes.js');

function fixture(rejections = 1) {
	const source = { id: 1, frame: { x: 0, y: 0, w: 1280, h: 800 }, fullFrame: { x: 0, y: 0, w: 1280, h: 800 } };
	const destination = { id: 2, frame: { x: 1280, y: 0, w: 2560, h: 1440 }, fullFrame: { x: 1280, y: 0, w: 2560, h: 1440 } };
	const screens = [source, destination];
	const timers = [];
	globalThis.HSRect = class {
		constructor(x, y, w, h) {
			Object.assign(this, { x, y, w, h });
		}
	};
	globalThis.hs = {
		userdefaults: { get: () => null },
		screen: { all: () => screens, primary: () => screens[0] },
		timer: {
			doAfter(delay, callback) {
				assert.equal(delay, 0.2);
				const timer = { callback, stopped: false, stop() { this.stopped = true; } };
				timers.push(timer);
				return timer;
			}
		},
		application: { runningApplications: () => [] }
	};
	const manager = new SDCWindows();
	let frame = { x: 0, y: 0, w: 1000, h: 700 };
	let writes = 0;
	const window = {
		pid: 10,
		id: 20,
		screen: source,
		application: { title: 'Code', isRunning: true },
		get frame() { return frame; },
		set frame(value) {
			writes++;
			this.screen = destination;
			frame = writes <= rejections ? { ...value, w: 1000, h: 700 } : value;
		}
	};
	return {
		manager, window, destination, screens,
		writes: () => writes,
		flush() {
			let callbacks = 0;
			while (timers.length) {
				assert.ok(callbacks++ < 10, 'retries must be bounded');
				const timer = timers.shift();
				if (!timer.stopped) timer.callback();
			}
		}
	};
}

test('cross-monitor placement corrects clamped sizes with bounded retries', () => {
	for (const rejections of [0, 1, 2, Infinity]) {
		const state = fixture(rejections);
		state.manager.placeWindow(state.window, state.destination, sizes.full);
		state.flush();
		assert.equal(state.writes(), Math.min(rejections + 1, 3));
		if (rejections !== Infinity) {
			assert.deepEqual(state.window.frame, state.manager.layoutFrame(state.destination, sizes.full));
		}
		assert.equal(state.manager.pendingPlacements.size, 0);
	}
});

test('Dock space stays reserved on the primary display when the Dock migrates', () => {
	const state = fixture(0);
	const [primary, secondary] = state.screens;
	const frames = () => state.screens.map(screen => ({ ...state.manager.usableFrame(screen) }));
	primary.frame = { x: 0, y: 0, w: 1280, h: 730 };
	const dockOnPrimary = frames();
	primary.frame = { ...primary.fullFrame };
	secondary.frame = { x: 1280, y: 0, w: 2560, h: 1370 };
	assert.deepEqual(frames(), dockOnPrimary);
	assert.deepEqual(dockOnPrimary, [{ x: 0, y: 0, w: 1280, h: 730 }, { ...secondary.fullFrame }]);
});

test('correctly aligned windows receive no redundant frame writes', () => {
	const state = fixture(0);
	state.manager.placeWindow(state.window, state.destination, sizes.full);
	state.flush();
	state.manager.placeWindow(state.window, state.destination, sizes.full);
	state.flush();
	assert.equal(state.writes(), 1);
});

test('new Messages windows use the laptop layout', () => {
	const state = fixture(0);
	state.screens.splice(1);
	globalThis.hs.screen.primary = () => state.screens[0];
	const window = { ...state.window, title: 'Messages' };
	const app = {
		title: 'Messages', bundleID: 'com.apple.MobileSMS', isRunning: true,
		allWindows: [window], mainWindow: window
	};
	window.application = app;
	state.manager.processCreatedWindow(app, { title: window.title });
	assert.deepEqual(window.frame, state.manager.layoutFrame(state.screens[0], sizes.halves.right));
});

test('reset places Messages even when name lookup matches its assistant extension', () => {
	const state = fixture(0);
	state.screens.splice(1);
	globalThis.hs.screen.primary = () => state.screens[0];
	const window = { ...state.window, title: 'Messages' };
	const app = {
		pid: 10, title: 'Messages', bundleID: 'com.apple.MobileSMS', isRunning: true,
		allWindows: [window], mainWindow: window
	};
	const helper = {
		pid: 11, title: 'Messages Assistant Extension',
		bundleID: 'com.apple.messages.AssistantExtension', isRunning: true, allWindows: []
	};
	window.application = app;
	globalThis.hs.application.matchingName = name => name === 'Messages' ? helper : null;
	globalThis.hs.application.matchingBundleID = bundleID => bundleID === app.bundleID ? app : null;
	state.manager.resetAllApps(false);
	assert.deepEqual(window.frame, state.manager.layoutFrame(state.screens[0], sizes.halves.right));
});

test('new placements cancel stale corrections', () => {
	const state = fixture();
	state.manager.placeWindow(state.window, state.destination, sizes.full);
	state.manager.placeWindow(state.window, state.destination, sizes.halves.left);
	state.flush();
	assert.equal(state.writes(), 2);
	assert.deepEqual(state.window.frame, state.manager.layoutFrame(state.destination, sizes.halves.left));
});

test('disconnection, app termination, and stop cancel corrections', () => {
	for (const reason of ['disconnect', 'terminate', 'stop']) {
		const state = fixture();
		state.manager.placeWindow(state.window, state.destination, sizes.full);
		if (reason === 'disconnect') state.screens.pop();
		if (reason === 'terminate') state.window.application.isRunning = false;
		if (reason === 'stop') state.manager.stop();
		state.flush();
		assert.equal(state.writes(), 1);
		assert.equal(state.manager.pendingPlacements.size, 0);
	}
});
