-- To find Hammerspoon preferences:
-- 1) Run Hammerspoon from Spotlight or run `open -a Hammerspoon` in the Terminal
-- 2) Press Command + Comma

spoon = {} -- fixes global spoon loading issue

-- require('hs.ipc') -- commandline 'hs' -- if CLI is not working, try `hs.ipc.cliInstall('/opt/homebrew')`
require('lib/common')

-- hs.notify.withdrawAll()
hs.autoLaunch(true)
hs.window.filter.setLogLevel(1)
hs.hotkey.setLogLevel(1)
-- hs.alert.defaultStyle.textSize = 40

if hs.updateAvailable() ~= false then
	hs.alert.show('Hammerspoon update available: ' .. hs.updateAvailable())
else
	hs.alert.show('Configuration loaded.')
end

require('lib/settings')
require('lib/spoons')

-- Reload Hammerspoon
-- local reloadWatcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', hs.reload):start()
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), '/', function()
	print('Hammerspoon is reloading')
	hs.reload()
end)

-- Move tab to new window and minimize old
hs.hotkey.bind({'cmd', 'option', 'shift'}, 'T', function()
	local app = hs.application.frontmostApplication()
	if contains(mapList(browsers(), 'name'), app:name()) then
		local workingTabMenu = 'Tab'
		if app:name() == 'Safari' then
			workingTabMenu = 'Window'
		end
		app:selectMenuItem({ workingTabMenu, 'Move Tab to New Window' })
		hs.eventtap.keyStroke({'cmd'}, '`')
		app:selectMenuItem({ 'Window', 'Minimize' })
	end
end)

hs.window.filter.new({ 'TextEdit', 'Obsidian' })
	:subscribe(hs.window.filter.windowCreated, function(window, appName, event)
		if #hs.application.get(appName):allWindows() == 1 then
			if window:title() ~= 'Open' and (not window:tabCount() or window:tabCount() < 2) then
				spoon.SDCWindows:windowMove(window, nil, windowSizeChooser(spoon.SDCWindows:getAppLayoutSettings(appName).sizes))
			end
		end
	end)

hs.window.filter.new(mapList(browsers(), 'name'))
	:subscribe(hs.window.filter.windowCreated, function(window, appName, event)
		local foundBrowser = findByKeyValue(browsers(), 'name', appName)
		if foundBrowser and foundBrowser.ignoreWindowTitles and contains(foundBrowser.ignoreWindowTitles, window:title()) then
			return
		end
		spoon.SDCWindows:windowMove(window, nil, windowSizeChooser(spoon.SDCWindows:getAppLayoutSettings(appName).sizes))
	end)

hs.window.filter.new({ 'Terminal', 'iTerm2' })
	:subscribe({
		hs.window.filter.windowCreated,
		hs.window.filter.windowDestroyed
	}, function(window, appName, event)
		workingWindow = window
		app = hs.application.get(appName)
		if event == 'windowDestroyed' and app ~= nil and app:isRunning() then
			if (#app:allWindows() < 1) then
				return
			end
			workingWindow = app:focusedWindow()
		elseif event == 'windowCreated' and app ~= nil and app:isRunning() then
			if string.find(workingWindow:title(), '⌥⌘1') then -- hack to determine if window has only 1 tab
				spoon.SDCWindows:windowMove(workingWindow, nil, windowSizeChooser(spoon.SDCWindows:getAppLayoutSettings(hs.settings.get('terminalAppName')).sizes))
			end
		end
		spoon.SDCWindows:moveWindowIfCloseToPreset(workingWindow)
	end)
	:subscribe(hs.window.filter.windowMoved, function()
		terminal = hs.application.get(hs.settings.get('terminalAppName'))
		if tertiaryMonitor and terminal:mainWindow():screen() == hs.screen.find(hs.settings.get('tertiaryMonitorNames')) then
			win = terminal:mainWindow()
			winUR = win:frame():toUnitRect(win:screen():frame())
			if (winUR.w > 0.51 and winUR.w < 1.00) or (winUR.h > 0.50 and winUR.h < 0.97) then
				terminal:mainWindow():moveToUnit(hs.layout.maximized)
			end
		end
	end)

local musicItunesLaunchWatcher = hs.application.watcher.new(function(name, event, app)
	if (app:bundleID() == 'com.apple.iTunes' or app:bundleID() == 'com.apple.Music') and (event == 0 or event == 1 or event == hs.application.watcher.launching or event == hs.application.watcher.launched) then
		app:kill9()
	end
end):start()

local preferredAudioInputName = 'Tempest'
local unpreferredAudioInputName = 'Desk Airpods Pro'

-- Function to check and switch audio input
local function switchAudioInput()
	local secondaryMonitorConnected = false
	local unpreferredAudioConnected = false
	for _, screen in ipairs(hs.screen.allScreens()) do
		if contains(hs.settings.get('secondaryMonitorNames'), screen:name()) then
			secondaryMonitorConnected = true
			break
		end
	end
	local devices = hs.audiodevice.allInputDevices()
	for _, device in ipairs(devices) do
		if device.name == unpreferredAudioInputName and device.connected then
			unpreferredAudioConnected = true
		end
	end
	if secondaryMonitorConnected or (secondaryMonitorConnected and unpreferredAudioConnected) then
		hs.execute("SwitchAudioSource -t input -s '" .. preferredAudioInputName .. "'")
	end
end

-- Watch for screen changes
local screenWatcher = hs.screen.watcher.new(function()
	hs.timer.doAfter(3, switchAudioInput)
end)

-- Start the screen watcher
screenWatcher:start()

switchAudioInput()

hs.audiodevice.watcher.setCallback(switchAudioInput)
hs.audiodevice.watcher.start()
