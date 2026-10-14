const defaults = {
	hotkeyCombo: ["cmd", "alt", "ctrl"],
	primaryMonitorName: "37D8832A-2D66-02CA-B9F7-8F30A301B230",
	secondaryMonitorMain: "Studio Display",
	secondaryMonitorAlt: "DELL P2415Q",
	tertiaryMonitorNames: [4128829, 3],
	terminalAppName: "Ghostty",
	windowGap: 8,
	deskSetup: "laptop"
}

const secondaryMonitorNames = [defaults.secondaryMonitorMain, defaults.secondaryMonitorAlt]
const deskLabels = {
	deskWithiPad: "Desk with iPad",
	desk: "Desk",
	deskAlt: "Desk (DELL)",
	laptopWithSide: "Laptop with Side Monitor",
	laptop: "Laptop"
}
const ignoreTitles = ["MenuBarCover"]

function setting(key) {
	const value = hs.userdefaults.get(key)
	return value ?? defaults[key]
}

module.exports = { defaults, secondaryMonitorNames, deskLabels, ignoreTitles, setting }
