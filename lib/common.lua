function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- https://gist.github.com/zwh8800/9b0442efadc97408ffff248bc8573064
function parse_json_date(json_date)
	local pattern = "(%d+)%-(%d+)%-(%d+)%a(%d+)%:(%d+)%:([%d%.]+)([Z%+%-])(%d?%d?)%:?(%d?%d?)"
	local year, month, day, hour, minute, seconds, offsetsign, offsethour, offsetmin = json_date:match(pattern)
	seconds = math.floor(tonumber(seconds))
	local timestamp = os.time{ year = year, month = month, day = day, hour = hour, min = minute, sec = seconds }
	local offset = 0
	-- if offsetsign ~= 'Z' then
	-- 	offset = tonumber(offsethour) * 60 + tonumber(offsetmin)
	-- 	if xoffset == "-" then offset = offset * -1 end
	-- end
	return timestamp + offset
end

function urlencode(url)
	-- https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99
  if not url then return end
  url = url:gsub("\n", "\r\n")
  url = url:gsub(" ", "+")
  return url
end

function contains(table, val)
  for i = 1, #table do
    if table[i] == val then
      return true
    end
  end
  return false
end

function settingExists(key)
	return contains(hs.settings.getKeys(), key) and type(hs.settings.get(key)) ~= nil
end

function setupSetting(key, message, informativeText, force)
	if not key then return false end
	if force or not settingExists(key) then
		button, text = hs.dialog.textPrompt(message or key, informativeText or '')
		hs.settings.set(key, text)
	end
	return hs.settings.get(key)
end

function screenIsConnected(screenName)
	if hs.screen.find(screenName) ~= nil then
		return true
	else
		return false
	end
end

function screenChooser(options)
	desiredScreenName = options[hs.settings.get('deskSetup')]
	if desiredScreenName ~= nil and screenIsConnected(desiredScreenName) then
		return hs.screen.find(desiredScreenName)
	else
		return hs.screen.primaryScreen()
	end
end

function windowSizeChooser(options)
	desiredSize = options[hs.settings.get('deskSetup')]
	if desiredSize ~= nil then
		return desiredSize
	else
		return hs.settings.get('windowSizes').center
	end
end

function toggleSidecariPad()
	hs.osascript.applescript([[
		tell application "System Events"
			tell process "SystemUIServer"
				click (menu bar item 1 of menu bar 1 whose description contains "Displays")
				set displaymenu to menu 1 of result
				click ((menu item 1 where its name contains "iPad") of displaymenu)
			end tell
		end tell
	]])
end

function minutesToClock(minutesGiven, includeZeroes, prettify)
	minutesGivenOriginal = minutesGiven
	minutesGiven = tonumber(minutesGiven)
	if not minutesGiven then
		minutesGiven = tostring(minutesGivenOriginal):match("%d+")
	end
	hours = math.floor(minutesGiven / 60)
	minutes = math.ceil(minutesGiven - hours * 60)
	hoursAppend = 'h'
	minutesAppend = 'm'
	if prettify then
		hoursAppend = ' hour'
		if hours ~= 1 then
			hoursAppend = hoursAppend .. 's'
		end
		minutesAppend = ' minute'
		if minutes ~= 1 then
			minutesAppend = minutesAppend .. 's'
		end
	end
	hoursString = string.format("%01.f" .. hoursAppend, hours)
	minutesString = string.format("%01.f" .. minutesAppend, minutes)
	if includeZeroes then
		minutesString = string.format("%02.f" .. minutesAppend, minutes)
	end
	clockString = ''
	if hours > 0 or includeZeroes then
		clockString = clockString .. hoursString
	end
	if minutes > 0 or includeZeroes or hours < 1 then
		spacer = ''
		if prettify and (hours > 0 or includeZeroes) then
			spacer = ' '
		end
		clockString = clockString .. spacer .. minutesString
	end
	return clockString
end

function isHome()
	if contains({ 'Kathryn', 'Kathryn-2' }, hs.wifi.currentNetwork()) then
		return true
	else
		return false
	end
end

-- hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'pagedown', function()
-- 	if spoon.SDCOvercast.player.isPlaying then
-- 		spoon.SDCOvercast:playerRewind()
-- 	elseif spoon.SDCMusic:getCurrentPlayerState() == 'playing' then
-- 		spoon.SDCMusic:playerRewind()
-- 	end
-- end)

-- hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'pageup', function()
-- 	if spoon.SDCOvercast.player.isPlaying then
-- 		spoon.SDCOvercast:playerFastForward()
-- 	elseif spoon.SDCMusic:getCurrentPlayerState() == 'playing' then
-- 		spoon.SDCMusic:playerFastForward()
-- 	end
-- end)
