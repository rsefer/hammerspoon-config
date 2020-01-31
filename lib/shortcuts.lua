-- Reload Hammerspoon
-- local reloadWatcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', hs.reload):start()
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), '/', function()
	if spoon.SDCTimer.timerMain:running() then
		spoon.SDCTimer:toggleTimer()
		hs.timer.usleep(2000000)
	end
	hs.reload()
end)

-- Restart Hammerspoon
-- (in Settings > Keyboard > Shortcuts)
-- {'cmd', 'alt', 'ctrl'}, -
-- The above is not included in the Hammerspoon config because they won't
-- work if Hammerspoon is not running (launch) or frozen (force quit)

-- Do Not Disturb toggle
-- (in Settings > Keyboard > Shortcuts)
-- {'cmd', 'alt', 'ctrl'}, f17

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

-- Dark Mode toggle
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'f16', function()
	hs.osascript.applescript('tell application "System Events" to tell appearance preferences to set dark mode to not dark mode')
end)

-- Toggle Sidecar for iPad
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'padenter', function()
	toggleSidecariPad()
end)
hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'I', function()
	toggleSidecariPad()
end)
