import { spawnSync } from 'node:child_process';
import { writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';

const versionPattern = /^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$/;

function installedVersion() {
	const result = spawnSync('hs2', ['--no-prompt'], {
		input: 'hs.appinfo.version',
		encoding: 'utf8'
	});
	if (result.error) throw new Error(`Could not run hs2: ${result.error.message}`);
	if (result.status !== 0) {
		throw new Error(`hs2 failed with status ${result.status}: ${result.stderr.trim()}`);
	}

	const output = `${result.stdout}\n${result.stderr}`;
	const version = output.split(/\r?\n/).map(line => line.trim()).find(line => versionPattern.test(line));
	if (!version) {
		throw new Error(`Could not parse Hammerspoon version from hs2 output: ${output.trim()}`);
	}
	return version;
}

const docsVersion = process.argv[2] || installedVersion();
if (!versionPattern.test(docsVersion)) {
	throw new Error(`Invalid Hammerspoon docs version: ${docsVersion}`);
}

const url = `https://cmsj.github.io/Hammerspoon2/${docsVersion}/hammerspoon.d.ts`;
const response = await fetch(url);
if (!response.ok) {
	throw new Error(`Could not download ${url}: ${response.status} ${response.statusText}`);
}

const declarations = await response.text();
if (!declarations.includes('declare namespace hs') || !declarations.includes('declare class HSRect')) {
	throw new Error(`Downloaded file from ${url} does not look like Hammerspoon declarations`);
}

const target = fileURLToPath(new URL('../hammerspoon.d.ts', import.meta.url));
await writeFile(target, declarations);
console.log(`Updated hammerspoon.d.ts from ${url}`);
