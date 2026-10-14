#!/usr/bin/env node
// raycast-window-gaps.js — read innerGap/outerGap from the latest Raycast settings snapshot

const fs = require("fs");
const path = require("path");
const os = require("os");

const snapDir = path.join(
  os.homedir(),
  "Library/Application Support/com.raycast.macos/cloud-sync/settings-snapshots"
);

const latest = fs
  .readdirSync(snapDir)
  .filter((f) => f.endsWith(".json"))
  .map((f) => ({ file: path.join(snapDir, f), mtime: fs.statSync(path.join(snapDir, f)).mtimeMs }))
  .sort((a, b) => b.mtime - a.mtime)[0]?.file;

if (!latest) {
  console.error("No settings snapshots found (is Cloud Sync enabled?)");
  process.exit(1);
}

const data = JSON.parse(fs.readFileSync(latest, "utf8"));
const ext = (data.tables?.internal_extensions ?? []).find((e) => e.id === "e:r:window-management");

if (!ext) {
  console.error("window-management entry not found in", latest);
  process.exit(1);
}

const meta = ext.syncedMeta ?? {};

if (process.argv.includes("--json")) {
  console.log(JSON.stringify({ innerGap: meta.innerGap, outerGap: meta.outerGap }));
} else {
  console.log("snapshot:", latest);
  console.log("innerGap:", meta.innerGap);
  console.log("outerGap:", meta.outerGap);
}
