-- Reload Hammerspoon
-- local reloadWatcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', hs.reload):start()
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), '/', function() hs.reload() end)

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
	hs.osascript.applescript('tell application "System Events" to tell appearance preferences to set dark mode to not dark mode')
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
