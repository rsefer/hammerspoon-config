const browsers = [
	{ name: "Safari", bundleID: "com.apple.Safari" },
	{ name: "Google Chrome", bundleID: "com.google.Chrome" },
	{ name: "Firefox", bundleID: "org.mozilla.firefox" },
	{ name: "Vivaldi", bundleID: "com.vivaldi.Vivaldi", ignoreWindowTitles: ["Updating Vivaldi"] },
	{ name: "Orion", bundleID: "com.kagi.macos", ignoreWindowTitles: ["Untitled", "Completions"] },
	{ name: "Zen", bundleID: "app.zen-browser.zen" },
	{ name: "Brave Browser", bundleID: "com.brave.Browser" },
	{ name: "Google Chrome Canary", bundleID: "com.google.Chrome.canary" },
	{ name: "Microsoft Edge", bundleID: "com.microsoft.edgemac" },
	{ name: "Arc", bundleID: "company.thebrowser.Browser" }
]

module.exports = { browsers }
