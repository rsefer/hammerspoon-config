hs.location.start()
hs.window.filter.setLogLevel(1)
hs.hotkey.setLogLevel(1)
hs.alert.defaultStyle.textSize = 40

-- clears Hammerspoon error notifications
hs.osascript.applescript([[
tell application "System Events" to tell process "NotificationCenter"
	repeat with thisWindow in windows
		if value of static text 1 of thisWindow is "Hammerspoon error" then click button "Close" of thisWindow
	end repeat
end tell
]])

if hs.updateAvailable() ~= false then
	hs.alert.show('Hammerspoon update available: ' .. hs.updateAvailable())
else
	hs.alert.show('Configuration loaded.')
end
