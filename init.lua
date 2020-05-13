-- To find Hammerspoon preferences:
-- 1) Run Hammerspoon from Spotlight or run `open -a Hammerspoon` in the Terminal
-- 2) Press Command + Comma

spoon = {} -- fixes global spoon loading issue

require('hs.ipc') -- commandline 'hs'
require('config')
require('lib/common')
require('lib/startup')

require('lib/settings')
require('lib/spoons')
require('lib/shortcuts')
require('lib/window-misc')
