import { spawn } from 'node:child_process';
import chokidar from 'chokidar';

let timer;
let running = false;
let pending = false;

const watcher = chokidar.watch([
	'config.ts', 'init.js', 'lib', 'scripts', 'eslint.config.mjs', 'tsconfig.json', 'tsconfig.node.json', 'hammerspoon.d.ts'
], { ignoreInitial: true });

function command(executable, args) {
	return new Promise(resolve => {
		const child = spawn(executable, args, { stdio: 'inherit' });
		child.on('error', error => {
			console.error(error.message);
			resolve(false);
		});
		child.on('exit', code => resolve(code === 0));
	});
}

async function rebuild() {
	if (running) {
		pending = true;
		return;
	}
	running = true;
	const success = await command('npm', ['run', 'lint:fix']) && await command('npm', ['run', 'build']);
	if (success) {
		const reloaded = await command('/usr/bin/open', ['-g', 'hammerspoon2://reload_config']);
		console.log(reloaded ? '[dev] Build complete. Hammerspoon reload requested.' : '[dev] Build complete, but reload failed. Reload Hammerspoon manually.');
	} else {
		console.log('[dev] Checks failed. Waiting for changes.');
	}
	running = false;
	if (pending) {
		pending = false;
		schedule();
	}
}

function schedule() {
	clearTimeout(timer);
	timer = setTimeout(rebuild, 200);
}

watcher.on('ready', rebuild);
watcher.on('all', schedule);
watcher.on('error', error => {
	console.error(error);
	process.exit(1);
});

console.log('[dev] Watching source files; linting, auto-fixing, compiling, and reloading Hammerspoon on save.');
