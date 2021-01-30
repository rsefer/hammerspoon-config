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

daysTarget = os.time({ year = 2022, month = 5, day = 7 })
daysMenubar = hs.menubar.new():setClickCallback(function()
	hs.execute('say "yay!" -r 250', true)
end)
function setDaysTitle()
	daysMenubar:setTitle(math.floor(os.difftime(daysTarget, os.time()) / (24 * 60 * 60)) .. ' days 👰‍♀️🤵')
end
setDaysTitle()
daysTimer = hs.timer.doEvery(60 * 5, setDaysTitle)

require('lib/spoons')
require('lib/shortcuts')
require('lib/window-misc')

