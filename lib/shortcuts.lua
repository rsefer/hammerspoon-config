-- Reload Hammerspoon
-- local reloadWatcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', hs.reload):start()
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), '/', function() hs.reload() end)

-- Force Quit Hammerspoon
-- (in Settings > Keyboard > Shortcuts)
-- {'cmd', 'alt', 'ctrl'}, -
-- Launch Hammerspoon
-- (in Settings > Keyboard > Shortcuts)
-- {'cmd', 'alt', 'ctrl'}, +
-- The above are not included in the Hammerspoon config because they won't
-- work if Hammerspoon is not running (launch) or frozen (force quit)

-- Location
if hs.location.servicesEnabled() and hs.location.authorizationStatus() == 'authorized' and hs.location.start() and hs.location.get() then
	location = hs.location.get()
	hs.settings.set('latitude', location.latitude)
	hs.settings.set('longitude', location.longitude)
	hs.location.register('updateLocationTag', function(locationTable)
		hs.settings.set('latitude', locationTable.latitude)
		hs.settings.set('longitude', locationTable.longitude)
	end, 400)
else
	hs.alert.show('⛅️Cannot retrieve lat/lng')
end

-- Google Query Suggestions
-- Based heavily on Andrew Hampton's "autocomplete"
-- https://github.com/andrewhampton/dotfiles/blob/8136fafe8aabee49f8cea0ab3da6c9e7be472e62/hammerspoon/.hammerspoon/anycomplete.lua
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'G', function()
	local GOOGLE_ENDPOINT = 'https://suggestqueries.google.com/complete/search?client=chrome&num=5&q=%s'
	local current = hs.application.frontmostApplication()
	local chooser = hs.chooser.new(function(choice)
		if not choice then return end
		current:activate()
		hs.eventtap.keyStrokes(choice.text)
	end)
	chooser:queryChangedCallback(function(string)
		local query = hs.http.encodeForQuery(string)
		hs.http.asyncGet(string.format(GOOGLE_ENDPOINT, query), nil, function(status, data)
			if not data then return end
			local ok, results = pcall(function() return hs.json.decode(data) end)
			if not ok then return end
			choices = hs.fnutils.imap(results[2], function(result)
				return { ['text'] = result }
			end)
			chooser:choices(choices)
		end)
	end)
	chooser:searchSubText(false)
	chooser:show()
end)

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

-- Toggle Sidecar for iPad
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'padenter', function()
	hs.osascript.applescript([[
		tell application "System Events"
			tell process "SystemUIServer"
				click (menu bar item 1 of menu bar 1 whose description contains "Displays")
				set displaymenu to menu 1 of result
				click ((menu item 1 where its name contains "iPad") of displaymenu)
			end tell
		end tell
	]])
end)

-- Mirror Display toggle
-- hs.hotkey.bind(hs.settings.get('hotkeyCombo'), '0', function()
-- 	hs.application.launchOrFocus('System Preferences')
-- 	hs.timer.doAfter(3, function()
-- 		hs.application.get('System Preferences'):selectMenuItem({'View', 'Displays'})
-- 		hs.timer.doAfter(1, function()
-- 			hs.window.focusedWindow():focusTab(2)
-- 		end)
-- 	end)
-- end)

-- Fixes constrast adjustment issue with Duet
-- hs.hotkey.bind(hs.settings.get('hotkeyCombo'), '=', function()
-- 	hs.osascript.applescript([[
-- 		tell application "System Preferences"
-- 			activate
-- 			reveal pane id "com.apple.preference.universalaccess"
-- 			delay 0.5
-- 		end tell
-- 		tell application "System Events"
-- 			select UI element 5 of table 1 of scroll area 1 of window 1 of application process "System Preferences"
-- 			delay 0.5
-- 			tell slider 1 of tab group 1 of group 1 of window 1 of application process "System Preferences" to set value to 0
-- 		end tell
-- 		tell application "System Preferences"
-- 			quit
-- 		end tell
-- 	]])
-- end)
