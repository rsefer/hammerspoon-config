hs.location.start()
hs.window.filter.setLogLevel(1)
hs.hotkey.setLogLevel(1)
hs.alert.defaultStyle.textSize = 40

-- clears Hammerspoon error notifications
hs.osascript.applescript([[
	tell application "System Events"
		tell process "NotificationCenter"
			set windowCount to count windows
			repeat with i from windowCount to 1 by -1
				if value of static text 1 of window i is "Hammerspoon error" then
					click button "Close" of window i
				end if
			end repeat
		end tell
	end tell
]])

if hs.updateAvailable() ~= false then
	hs.alert.show('Hammerspoon update available: ' .. hs.updateAvailable())
else
	hs.alert.show('Configuration loaded.')
end
