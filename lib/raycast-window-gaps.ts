#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';

interface RaycastSnapshot {
	tables?: {
		internal_extensions?: {
			id: string;
			syncedMeta?: { innerGap?: number; outerGap?: number };
		}[];
	};
}

const snapDir = path.join(
	os.homedir(),
	'Library/Application Support/com.raycast.macos/cloud-sync/settings-snapshots'
);

const latest = fs
	.readdirSync(snapDir)
	.filter(file => file.endsWith('.json'))
	.map(file => ({ file: path.join(snapDir, file), mtime: fs.statSync(path.join(snapDir, file)).mtimeMs }))
	.sort((first, second) => second.mtime - first.mtime)[0]?.file;

if (!latest) {
	console.error('No settings snapshots found (is Cloud Sync enabled?)');
	process.exit(1);
}

const data = JSON.parse(fs.readFileSync(latest, 'utf8')) as RaycastSnapshot;
const ext = (data.tables?.internal_extensions ?? []).find(extension => extension.id === 'e:r:window-management');

if (!ext) {
	console.error('window-management entry not found in', latest);
	process.exit(1);
}

const meta = ext.syncedMeta ?? {};

if (process.argv.includes('--json')) {
	console.log(JSON.stringify({ innerGap: meta.innerGap, outerGap: meta.outerGap }));
} else {
	console.log('snapshot:', latest);
	console.log('innerGap:', meta.innerGap);
	console.log('outerGap:', meta.outerGap);
}