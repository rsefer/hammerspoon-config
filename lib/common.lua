function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function urlencode(url)
	-- https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99
  if url == nil then
    return
  end
  url = url:gsub("\n", "\r\n")
  url = url:gsub(" ", "+")
  return url
end

function tablelength(t)
	local count = 0
	for _ in pairs(t) do count = count + 1 end
	return count
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
	return contains(hs.settings.getKeys(), key) and string.len(hs.settings.get(key)) > 0
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
