import { spawnSync } from 'node:child_process';

const appName = 'Hammerspoon 2';
const appStatus = spawnSync('osascript', ['-e', `application "${appName}" is running`], {
	encoding: 'utf8'
});

if (appStatus.error || appStatus.status !== 0) {
	throw new Error(`Could not check whether ${appName} is running: ${appStatus.error?.message || appStatus.stderr.trim()}`);
}

if (appStatus.stdout.trim() !== 'true') {
	const launch = spawnSync('/usr/bin/open', ['-g', '-a', appName], { encoding: 'utf8' });
	if (launch.error || launch.status !== 0) {
		throw new Error(`Could not launch ${appName}: ${launch.error?.message || launch.stderr.trim()}`);
	}
	console.log(`[start] Launched ${appName}.`);
}

const deadline = Date.now() + 30_000;
let lastError = '';
while (Date.now() < deadline) {
	const ipc = spawnSync('hs2', ['--no-prompt'], {
		input: 'hs.appinfo.version',
		encoding: 'utf8'
	});
	if (ipc.status === 0) break;
	lastError = ipc.error?.message || ipc.stderr.trim();
	await new Promise(resolve => setTimeout(resolve, 500));
}

if (Date.now() >= deadline) {
	throw new Error(`${appName} IPC did not become available within 30 seconds. Ensure its loaded config calls hs.ipc.start().${lastError ? `\n${lastError}` : ''}`);
}

await import('./update-hammerspoon-types.mjs');
await import('./dev.mjs');