-- To find Hammerspoon preferences:
-- 1) Run Hammerspoon from Spotlight or run `open -a Hammerspoon` in the Terminal
-- 2) Press Command + Comma

spoon = {} -- fixes global spoon loading issue

require('hs.ipc') -- commandline 'hs' -- if CLI is not working, try `hs.ipc.cliInstall('/opt/homebrew')`
require('lib/common')
require('lib/startup')

require('lib/settings')
require('lib/icons')

local daysToWedding = 0
daysTarget = os.time({ year = 2023, month = 7, day = 9, hour = 0 })
daysMenubar = hs.menubar.new():autosaveName('Personal Countdown'):setClickCallback(function()
	hs.execute('say "yay! ' .. daysToWedding .. ' days to go"')
end)
function setDaysTitle()
	daysToWedding = math.ceil(os.difftime(daysTarget, os.time()) / (24 * 60 * 60))
	suffix = 's'
	if daysToWedding == 1 then
		suffix = ''
	end
	daysMenubar:setTitle(daysToWedding .. ' day' .. suffix .. ' 🐣')
end
setDaysTitle()
daysTimer = hs.timer.doEvery(60 * 1, setDaysTitle)

require('lib/spoons')
require('lib/shortcuts')
require('lib/window-misc')

