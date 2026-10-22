import { defaults } from './defaults.js';
import { sizes, type GridSize } from './window-sizes.js';
import { browsers } from './browsers.js';

export type ScreenOptions = Record<string, string | number | (string | number)[] | null>;
export type SizeOptions = Record<string, GridSize>;

interface WindowLayout {
	apps: string[];
	screens: ScreenOptions;
	sizes: SizeOptions;
}

const browserApps = browsers.flatMap(app => [app.bundleID, app.name]);
export const windowLayout: WindowLayout[] = [
	{
		apps: browserApps.concat([
			'SDC RSS', 'com.apple.Music', 'Spotify', 'Photos', 'App Store', 'Coda', 'com.apple.TV',
			'com.apple.news', 'com.apple.podcasts', 'Postman', 'Shortcuts', 'Weather', 'io.robbie.HomeAssistant'
		]),
		screens: { deskAlt: defaults.secondaryMonitorAlt, desk: null, laptopWithSide: null, laptop: null },
		sizes: { deskAlt: sizes.thirds.left2, desk: sizes.halves.left, laptopWithSide: sizes.full, laptop: sizes.full }
	},
	{
		apps: ['com.apple.MobileSMS', 'X', 'com.apple.Home', 'Hammerspoon', 'Reminders', 'Slack', 'com.apple.Notes'],
		screens: { deskAlt: defaults.secondaryMonitorAlt, desk: defaults.primaryMonitorName, laptopWithSide: null, laptop: null },
		sizes: { deskAlt: sizes.thirds.right, desk: sizes.halves.left, laptopWithSide: sizes.thirds.right, laptop: sizes.halves.right }
	},
	{
		apps: ['Code', '1Password'],
		screens: { deskAlt: defaults.primaryMonitorName, desk: null, laptopWithSide: defaults.tertiaryMonitorNames, laptop: null },
		sizes: { deskAlt: sizes.full, desk: sizes.halves.right, laptopWithSide: sizes.full, laptop: sizes.full }
	},
	{
		apps: ['TextEdit', 'Obsidian'],
		screens: { deskAlt: defaults.primaryMonitorName, desk: defaults.primaryMonitorName, laptopWithSide: null, laptop: null },
		sizes: { deskAlt: sizes.halves.left, desk: sizes.halves.left, laptopWithSide: sizes.halves.right, laptop: sizes.halves.right }
	},
	{
		apps: ['Photoshop', 'Illustrator', 'XD', 'UltiMaker Cura', 'Fusion 360', 'Inkscape'],
		screens: { deskAlt: null, desk: null, laptopWithSide: null, laptop: null },
		sizes: { deskAlt: sizes.full, desk: sizes.full, laptopWithSide: sizes.full, laptop: sizes.full }
	},
	{
		apps: ['Spotify', 'Local', 'Fantastical', 'GitHub Desktop', 'ClickUp'],
		screens: { deskAlt: defaults.primaryMonitorName, desk: defaults.primaryMonitorName, laptopWithSide: defaults.primaryMonitorName, laptop: defaults.primaryMonitorName },
		sizes: { deskAlt: sizes.full, desk: sizes.full, laptopWithSide: sizes.full, laptop: sizes.full }
	},
	{
		apps: ['Mail', 'Spark', 'Spark Desktop', 'Mimestream'],
		screens: { deskAlt: defaults.primaryMonitorName, desk: defaults.primaryMonitorName, laptopWithSide: defaults.tertiaryMonitorNames, laptop: defaults.primaryMonitorName },
		sizes: { deskAlt: sizes.full, desk: sizes.full, laptopWithSide: sizes.full, laptop: sizes.full }
	},
	{
		apps: ['Terminal', 'iTerm2', 'Ghostty', 'ChatGPT'],
		screens: { deskAlt: defaults.primaryMonitorName, desk: defaults.primaryMonitorName, laptopWithSide: defaults.primaryMonitorName, laptop: defaults.primaryMonitorName },
		sizes: { deskAlt: sizes.halves.right, desk: sizes.halves.right, laptopWithSide: sizes.full, laptop: sizes.halves.right }
	}
];
