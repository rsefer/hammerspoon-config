-- Reload Hammerspoon
-- local reloadWatcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', hs.reload):start()
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), '/', function()
  hs.reload()
end)

-- Force Quit Hammerspoon
-- (in Settings > Keyboard > Shortcuts)
-- {'cmd', 'alt', 'ctrl'}, -

-- Launch Hammerspoon
-- (in Settings > Keyboard > Shortcuts)
-- {'cmd', 'alt', 'ctrl'}, +

-- New Google Calendar Event
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), '8', function()
	hs.urlevent.openURL('https://calendar.google.com/calendar/r/eventedit')
end)

-- Do Not Disturb toggle
-- (in Settings > Keyboard > Shortcuts)
-- {'cmd', 'alt', 'ctrl'}, f17

-- Dark Mode toggle
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'f16', function()
	hs.osascript.applescript([[
		tell application "System Events"
			tell appearance preferences
				set dark mode to not dark mode
			end tell
		end tell
	]])
end)

-- Mirror Display toggle
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), '0', function()
	hs.application.launchOrFocus('System Preferences')
	hs.timer.doAfter(3, function()
		hs.application.get('System Preferences'):selectMenuItem({'View', 'Displays'})
		hs.timer.doAfter(1, function()
			hs.window.focusedWindow():focusTab(2)
		end)
	end)
end)

-- Eject key puts computer to sleep
-- hs.eventtap.new({ hs.eventtap.event.types.NSSystemDefined }, function(event)
--	event = event:systemKey()
--	local next = next
--	if next(event) then
--		if event.key == 'EJECT' and event.down then
--			hs.caffeinate.systemSleep()
--		end
--	end
--end):start()

-- Watch Terminal app when (un)plugging iPad as monitor
terminalWatcher = hs.screen.watcher.new(function()
	terminal = hs.application.find('Terminal')
	tertiaryMonitor = hs.screen.find(hs.settings.get('tertiaryMonitorName'))
	if terminal:isRunning() then
		if tertiaryMonitor then
			hs.timer.doAfter(1, function()
				terminal:mainWindow():moveToScreen(tertiaryMonitor)
				spoon.SDCWindows:gridset(0, 0, 100, 100, nil, terminal)
			end)
		else
			hs.timer.doAfter(1, function()
				terminal:mainWindow():focus()
				spoon.SDCWindows:gridset(50, 0, 50, 100, nil, terminal)
				terminal:hide()
			end)
		end
	end
end)
terminalWatcher:start()

local wf = hs.window.filter
wf_terminal = wf.new(false):setAppFilter('Terminal'):subscribe(hs.window.filter.windowMoved, function()
	terminal = hs.application.find('Terminal')
	tertiaryMonitor = hs.screen.find(hs.settings.get('tertiaryMonitorName'))
	if tertiaryMonitor and terminal:mainWindow():screen() == tertiaryMonitor then
		grid = hs.grid.get(terminal:mainWindow())
		if (grid.w > 50 and grid.w < 100) or (grid.h > 50 and grid.h < 97) then
			spoon.SDCWindows:gridset(0, 0, 100, 100, nil, terminal)
		end
	end
end)