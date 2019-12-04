-- To find Hammerspoon preferences:
-- 1) Run Hammerspoon from Spotlight or run `open -a Hammerspoon` in the Terminal
-- 2) Press Command + Comma

spoon = {} -- fixes global spoon loading issue
hs.location.start()
hs.window.filter.setLogLevel(1)
hs.hotkey.setLogLevel(1)
hs.alert.defaultStyle.textSize = 60

require('hs.ipc') -- commandline 'hs'
require('config')
require('lib/common')
require('lib/settings')
require('lib/spoons')
require('lib/shortcuts')
require('lib/window-misc')

if hs.updateAvailable() ~= false then
	hs.alert.show('Hammerspoon update available: ' .. hs.updateAvailable())
else
	hs.alert.show('Configuration loaded.')
end
