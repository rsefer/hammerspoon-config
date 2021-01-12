-- To find Hammerspoon preferences:
-- 1) Run Hammerspoon from Spotlight or run `open -a Hammerspoon` in the Terminal
-- 2) Press Command + Comma

spoon = {} -- fixes global spoon loading issue

require('hs.ipc') -- commandline 'hs'
require('config')
require('lib/common')
require('lib/startup')

require('lib/settings')
require('lib/icons')

local daysTarget = os.time({ year = 2021, month = 12, day = 3 })
local daysSuffix = ' days to go'
local daysMenubar = hs.menubar.new():setClickCallback(function()
	hs.execute('say "yay!"', true)
end)
function setDaysTitle()
	daysMenubar:setTitle(math.floor(os.difftime(daysTarget, os.time()) / (24 * 60 * 60)) .. ' days to go 👰‍♀️🤵')
end
setDaysTitle()
local daysTimer = hs.timer.doEvery(60 * 60 * 6, setDaysTitle)

require('lib/spoons')
require('lib/shortcuts')
require('lib/window-misc')

