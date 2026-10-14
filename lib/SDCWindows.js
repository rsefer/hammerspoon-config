const { setting, secondaryMonitorNames, deskLabels, ignoreTitles } = require("./defaults.js")
const { sizes, gridWidth, gridHeight } = require("./window-sizes.js")
const { browsers } = require("./browsers.js")
const { windowLayout } = require("./window-layout.js")
const gapRefreshInterval = 30

class SDCWindows {
	constructor() {
		this.currentDeskSetup = setting("deskSetup")
		this.appListener = null
		this.appTerminateListener = null
		this.watchedApps = new Map()
		this.raycastGaps = {
			innerGap: setting("innerGap") ?? setting("windowGap"),
			outerGap: setting("outerGap") ?? setting("windowGap")
		}
		this.gapRefreshEnabled = false
		this.gapRefreshPending = false
		this.gapRefreshGeneration = 0
		this.gapRefreshTask = null
		this.gapRefreshTimer = null
		this.lastGapRefreshError = null
	}

	layoutForApp(app) {
		if (!app) return null
		return windowLayout.find(layout => layout.apps.includes(app.title) || layout.apps.includes(app.bundleID)) || null
	}

	chooseScreen(options) {
		const deskSetup = setting("deskSetup")
		const desired = options ? options[deskSetup] : null
		const names = Array.isArray(desired) ? desired : [desired]
		for (const name of names) {
			if (name == null) continue
			const match = hs.screen.all().find(screen => screen.name === name || screen.id === name)
			if (match) return match
		}

		if (["desk", "deskWithiPad", "deskAlt"].includes(deskSetup)) {
			for (const name of secondaryMonitorNames) {
				const match = hs.screen.all().find(screen => screen.name === name || screen.id === name)
				if (match) return match
			}
		}
		return hs.screen.primary()
	}

	chooseSize(options) {
		return (options && options[setting("deskSetup")]) || sizes.center
	}

	layoutFrame(screen, size) {
		const bounds = screen.frame
		const { innerGap, outerGap } = this.raycastGaps
		const left = size[0] === 0 ? outerGap : innerGap / 2
		const top = size[1] === 0 ? outerGap : innerGap / 2
		const right = size[0] + size[2] >= gridWidth ? outerGap : innerGap / 2
		const bottom = size[1] + size[3] >= gridHeight ? outerGap : innerGap / 2
		const x = bounds.x + bounds.w * size[0] / gridWidth
		const y = bounds.y + bounds.h * size[1] / gridHeight
		const width = bounds.w * size[2] / gridWidth
		const height = bounds.h * size[3] / gridHeight
		return new HSRect(x + left, y + top, width - left - right, height - top - bottom)
	}

	refreshRaycastGaps() {
		if (!this.gapRefreshEnabled || this.gapRefreshPending) return

		const generation = this.gapRefreshGeneration
		const helperPath = `${hs.appinfo.configDir}/lib/raycast-window-gaps.js`
		const homePath = hs.fs.homeDirectory()
		const nodePath = `${homePath}/.local/share/fnm/aliases/default/bin`
		const inheritedPath = hs.appinfo.environment.PATH || "/usr/bin:/bin:/usr/sbin:/sbin"
		const environment = {
			HOME: homePath,
			PATH: [nodePath, "/opt/homebrew/bin", "/usr/local/bin", inheritedPath].join(":")
		}
		let stdout = ""
		let stderr = ""

		try {
			this.gapRefreshPending = true
			this.gapRefreshTask = hs.task.create(
				"/usr/bin/env",
				["node", helperPath, "--json"],
				(exitCode, reason) => {
					if (generation !== this.gapRefreshGeneration) return
					this.gapRefreshTask = null
					this.gapRefreshPending = false
					if (!this.gapRefreshEnabled) return

					if (exitCode !== 0) {
					this.logGapRefreshError(stderr.trim() || `helper exited with ${reason}`)
					return
					}

					try {
						const gaps = JSON.parse(stdout)
						if (!Number.isFinite(gaps.innerGap) || !Number.isFinite(gaps.outerGap) || gaps.innerGap < 0 || gaps.outerGap < 0) {
							throw new Error("helper returned invalid gap values")
						}
						const changed = gaps.innerGap !== this.raycastGaps.innerGap || gaps.outerGap !== this.raycastGaps.outerGap
						this.raycastGaps = { innerGap: gaps.innerGap, outerGap: gaps.outerGap }
						this.lastGapRefreshError = null
						if (changed) this.resetAllApps(false)
					} catch (error) {
						this.logGapRefreshError(error.message)
					}
				},
				environment,
				(stream, output) => {
					if (stream === "stdout") stdout += output
					else stderr += output
				}
			)
			this.gapRefreshTask.start()
		} catch (error) {
			this.gapRefreshPending = false
			this.gapRefreshTask = null
			this.logGapRefreshError(error.message)
		}
	}

	logGapRefreshError(message) {
		if (message !== this.lastGapRefreshError) {
			console.warn(`[SDCWindows] Could not refresh Raycast gaps: ${message}`)
		}
		this.lastGapRefreshError = message
	}

	gridPosition(window) {
		const frame = window.frame
		const bounds = window.screen.frame
		return [
			(frame.x - bounds.x) / bounds.w * gridWidth,
			(frame.y - bounds.y) / bounds.h * gridHeight,
			frame.w / bounds.w * gridWidth,
			frame.h / bounds.h * gridHeight
		]
	}

	isCloseToSize(window, size) {
		const actual = this.gridPosition(window)
		return actual.every((value, index) => Math.abs(value - size[index]) <= 5)
	}

	closestPresetSize(window) {
		for (const value of Object.values(sizes)) {
			if (Array.isArray(value) && this.isCloseToSize(window, value)) return value
			if (value && typeof value === "object") {
				for (const candidate of Object.values(value)) {
					if (Array.isArray(candidate) && this.isCloseToSize(window, candidate)) return candidate
				}
			}
		}
		return null
	}

	placeWindow(window, screen, size) {
		if (!window) window = hs.window.focusedWindow()
		if (!window || !window.screen) return
		const targetScreen = screen || window.screen
		if (!targetScreen || !size) return

		const frame = this.layoutFrame(targetScreen, size)
		const appName = window.application && window.application.title

		if (appName === "Terminal") {
			const terminalFontSize = setting("tertiaryMonitorNames").includes(targetScreen.id) ? 20 : 14
			hs.osascript.applescript(`tell application "Terminal" to set the font size of window 1 to ${terminalFontSize}`)
		}
		window.frame = frame
	}

	appMove(app, screen, size) {
		if (!app || !app.title || !app.isRunning) return
		if (ignoreTitles.includes(app.title)) return
		app.allWindows.forEach(window => this.placeWindow(window, screen, size))
	}

	processCreatedWindow(app, element) {
		if (!app || !app.isRunning) return
		const title = element && element.title
		const window = app.allWindows.find(candidate => candidate.title === title) || app.mainWindow
		if (!window || ignoreTitles.includes(window.title)) return

		const browser = browsers.find(item => item.name === app.title || item.bundleID === app.bundleID)
		if (browser) {
			if (browser.ignoreWindowTitles && browser.ignoreWindowTitles.includes(window.title)) return
			const layout = this.layoutForApp(app)
			if (layout) this.placeWindow(window, this.chooseScreen(layout.screens), this.chooseSize(layout.sizes))
			return
		}

		if (["TextEdit", "Obsidian"].includes(app.title)) {
			if (app.allWindows.length === 1 && window.title !== "Open") {
				const layout = this.layoutForApp(app)
				if (layout) this.placeWindow(window, this.chooseScreen(layout.screens), this.chooseSize(layout.sizes))
			}
			return
		}

		if (["Terminal", "iTerm2", "Ghostty"].includes(app.title)) {
			if (window.title.includes("⌥⌘1")) {
				const layout = this.layoutForApp(app)
				if (layout) this.placeWindow(window, this.chooseScreen(layout.screens), this.chooseSize(layout.sizes))
			}
			this.moveWindowIfCloseToPreset(window)
		}
	}

	processTerminalMove(app, element) {
		if (!app || !app.isRunning) return
		const window = app.allWindows.find(candidate => candidate.title === (element && element.title)) || app.mainWindow
		if (!window) return
		this.moveWindowIfCloseToPreset(window)

		if (app.title !== setting("terminalAppName")) return
		const tertiary = setting("tertiaryMonitorNames").includes(window.screen.id)
		const frame = window.frame
		const screenFrame = window.screen.frame
		const width = frame.w / screenFrame.w
		const height = frame.h / screenFrame.h
		if (tertiary && ((width > 0.51 && width < 1) || (height > 0.5 && height < 0.97))) {
			window.frame = new HSRect(screenFrame.x, screenFrame.y, screenFrame.w, screenFrame.h)
		}
	}

	moveWindowIfCloseToPreset(window) {
		const size = this.closestPresetSize(window)
		if (size) this.placeWindow(window, window.screen, size)
	}

	watchApp(app) {
		if (!app || this.watchedApps.has(app.pid) || !this.layoutForApp(app)) return
		const element = app.axElement()
		if (!element) return

		const notifications = [hs.ax.notificationTypes.windowCreated]
		const isTerminal = ["Terminal", "iTerm2", "Ghostty"].includes(app.title)
		if (isTerminal) notifications.push(hs.ax.notificationTypes.windowMoved)
		const listener = (notification, windowElement) => {
			if (notification === hs.ax.notificationTypes.windowCreated) {
				hs.timer.doAfter(0.2, () => this.processCreatedWindow(app, windowElement))
			} else if (notification === hs.ax.notificationTypes.windowMoved && isTerminal) {
				hs.timer.doAfter(0.2, () => this.processTerminalMove(app, windowElement))
			}
		}

		try {
			hs.ax.on(element, notifications, listener)
			this.watchedApps.set(app.pid, { element, notifications, listener })
		} catch (error) {
			console.warn(`[SDCWindows] Could not watch ${app.title}: ${error.message}`)
		}
	}

	unwatchApp(app) {
		if (!app) return
		const watcher = this.watchedApps.get(app.pid)
		if (!watcher) return
		hs.ax.off(watcher.element, watcher.notifications, watcher.listener)
		this.watchedApps.delete(app.pid)
	}

	resetAllApps(showAlert = true) {
		const deskSetup = setting("deskSetup")
		if (showAlert) hs.ui.alert(`Desk Setup: ${deskLabels[deskSetup] || deskSetup}`).duration(2).show()
		windowLayout.forEach(layout => {
			const screen = this.chooseScreen(layout.screens)
			const size = this.chooseSize(layout.sizes)
			layout.apps.forEach(name => {
				const app = hs.application.matchingName(name) || hs.application.matchingBundleID(name)
				this.appMove(app, screen, size)
			})
		})
	}

	setDeskSetup(value) {
		const oldValue = this.currentDeskSetup
		if (!value || value === oldValue) return
		if (oldValue === "deskWithiPad" && value === "laptopWithSide") {
			hs.userdefaults.set("deskSetup", "laptop")
			return
		}

		this.currentDeskSetup = value
		deskLabels[value] = deskLabels[value] || value
		hs.userdefaults.set("deskSetup", value)
		hs.userdefaults.set("deskSetupLabel", deskLabels[value])
		this.resetAllApps()
	}

	start() {
		if (this.appListener) return this
		this.gapRefreshEnabled = true
		this.gapRefreshGeneration += 1
		this.gapRefreshTimer = hs.timer.doEvery(gapRefreshInterval, () => this.refreshRaycastGaps())
		this.refreshRaycastGaps()
		this.appListener = app => this.watchApp(app)
		this.appTerminateListener = app => this.unwatchApp(app)
		hs.application.on("didLaunch", this.appListener)
		hs.application.on("didTerminate", this.appTerminateListener)
		hs.application.runningApplications().forEach(app => this.watchApp(app))
		return this
	}

	stop() {
		this.gapRefreshEnabled = false
		this.gapRefreshGeneration += 1
		if (this.gapRefreshTimer) this.gapRefreshTimer.stop()
		if (this.gapRefreshTask) this.gapRefreshTask.terminate()
		this.gapRefreshTimer = null
		this.gapRefreshTask = null
		this.gapRefreshPending = false
		if (this.appListener) hs.application.off("didLaunch", this.appListener)
		if (this.appTerminateListener) hs.application.off("didTerminate", this.appTerminateListener)
		for (const app of hs.application.runningApplications()) this.unwatchApp(app)
		this.appListener = null
		this.appTerminateListener = null
		this.watchedApps.clear()
		return this
	}
}

module.exports = SDCWindows
