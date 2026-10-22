interface Settings {
	hotkeyCombo: string[];
	primaryMonitorName: string;
	secondaryMonitorMain: string;
	secondaryMonitorAlt: string;
	tertiaryMonitorNames: number[];
	terminalAppName: string;
	windowGap: number;
	deskSetup: string;
	innerGap?: number;
	outerGap?: number;
}

export const defaults: Settings = {
	hotkeyCombo: ['cmd', 'alt', 'ctrl'],
	primaryMonitorName: '37D8832A-2D66-02CA-B9F7-8F30A301B230',
	secondaryMonitorMain: 'Studio Display',
	secondaryMonitorAlt: 'DELL P2415Q',
	tertiaryMonitorNames: [4128829],
	terminalAppName: 'Ghostty',
	windowGap: 8,
	deskSetup: 'laptop'
};

export const secondaryMonitorNames = [defaults.secondaryMonitorMain, defaults.secondaryMonitorAlt];
export const deskLabels: Record<string, string> = {
	deskWithiPad: 'Desk with iPad',
	desk: 'Desk',
	deskAlt: 'Desk (DELL)',
	laptopWithSide: 'Laptop with Side Monitor',
	laptop: 'Laptop'
};
export const ignoreTitles = ['MenuBarCover'];

export function detectDeskSetup(screens = hs.screen.all()): string {
	const matches = (identifier: string | number) => screens.some(screen =>
		screen.name === identifier || screen.id === identifier || screen.uuid === identifier);
	const hasSideMonitor = setting('tertiaryMonitorNames').some(matches);
	if (matches(setting('secondaryMonitorMain'))) return hasSideMonitor ? 'deskWithiPad' : 'desk';
	if (matches(setting('secondaryMonitorAlt'))) return 'deskAlt';
	return hasSideMonitor ? 'laptopWithSide' : 'laptop';
}

export function setting<Key extends keyof Settings>(key: Key): Settings[Key] {
	const value = hs.userdefaults.get(key) as Settings[Key] | null | undefined;
	return value ?? defaults[key];
}
