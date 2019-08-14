-- To find Hammerspoon preferences:
-- 1) Run Hammerspoon from Spotlight or run `open -a Hammerspoon` in the Terminal
-- 2) Press Command + Comma

dofile('config.lua')

function script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  return str:match("(.*/)")
end

local hotkeyCombo = {'cmd', 'alt', 'ctrl'}
local computerName = hs.host.localizedName()
local screenClass = 'large' -- assumes large iMac
if string.match(string.lower(computerName), 'macbook') then
  screenClass = 'small'
end
local secondaryMonitorName = 'DELL P2415Q'
local tertiaryMonitorName = 'Yam Display'

-- Spoons

-- hs.loadSpoon('SDCDesktopCapture')

hs.loadSpoon('SDCWindows')
spoon.SDCWindows:bindHotkeys({
	resetWindows										= {hotkeyCombo, 'f18'},
  sizeLeftHalf                    = {hotkeyCombo, 'L'},
  sizeRightHalf                   = {hotkeyCombo, 'R'},
  sizeFull                        = {hotkeyCombo, 'F'},
  sizeCentered                    = {hotkeyCombo, 'C'},
  sizeLeft34ths                   = {hotkeyCombo, 'N'},
  size34thsCentered               = {hotkeyCombo, 'X'},
  sizeRight14th                   = {hotkeyCombo, 'M'},
  sizeRight14thTopHalfish         = {hotkeyCombo, ','},
  sizeRight14thBottomHalfish      = {hotkeyCombo, '.'},
  sizeHalfHeightTopEdge           = {hotkeyCombo, 'T'},
  sizeHalfHeightBottomEdge        = {hotkeyCombo, 'B'},
  moveLeftEdge                    = {hotkeyCombo, ';'},
  moveRightEdge                   = {hotkeyCombo, "'"}
})
spoon.SDCWindows:setSecondaryMonitor(secondaryMonitorName)
spoon.SDCWindows:setTertiaryMonitor(tertiaryMonitorName)
spoon.SDCWindows:setWatchedApps({
  {
    names = {'Terminal'},
    small = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 },
    large = { x1 = 73, y1 = 0, w1 = 27, h1 = 100, nickname = '14th' },
		withMultipleMonitors = 'tertiary'
  },
  {
    names = {'TextEdit'},
    small = { x1 = 50, y1 = 0, w1 = 50, h1 = 100 },
    large = { x1 = 73, y1 = 60, w1 = 27, h1 = 40 },
		withMultipleMonitors = 'primary'
  },
  {
    names = {'Visual Studio Code', 'Code', 'Atom', 'GitHub Desktop'},
    delay = 1,
    small = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 },
    large = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 },
		withMultipleMonitors = 'secondary'
  },
  {
    names = {'Google Chrome'},
    delay = true,
    small = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 },
    large = { x1 = 0, y1 = 0, w1 = 73, h1 = 100, nickname = '34ths' },
		withMultipleMonitors = 'primary'
  },
  {
    names = {'Tweetbot'},
    small = { x1 = 50, y1 = 0, w1 = 50, h1 = 100, doAfter = {
      x1 = 'opp', y1 = 'current', w1 = 'current', h1 = 'current'
    } },
    large = { x1 = 73, y1 = 0, w1 = 27, h1 = 55 },
		withMultipleMonitors = 'primary'
  }
})
spoon.SDCWindows:start()

hs.loadSpoon('SDCHomeAssistant')
spoon.SDCHomeAssistant:setConfig(keys.homeassistant_api_endpoint, keys.homeassistant_api_key)
spoon.SDCHomeAssistant:setWatchedApps({
  -- {
  --   name = 'Terminal',
  --   monitor = tertiaryMonitorName,
	-- 	large = { x1 = 73, y1 = 0, w1 = 27, h1 = 100, nickname = '14th' }
	-- },
	{
    name = 'Visual Studio Code',
    monitor = secondaryMonitorName,
		large = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 }
  },
	{
    name = 'Atom',
    monitor = secondaryMonitorName,
		large = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 }
  },
	{
    name = 'GitHub Desktop',
    monitor = secondaryMonitorName,
		large = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 }
  }
})
spoon.SDCHomeAssistant:bindHotkeys({
  switchLights = {hotkeyCombo, 'f19'}
})
spoon.SDCHomeAssistant:start()
spoon.SDCHomeAssistant:toggleSecondaryMonitor('on')

hs.loadSpoon('SDCAudio')
spoon.SDCAudio:setConfig({
  {
    order = 1,
    name = 'Built-in Output',
    menuIcon = '🖥',
    alertIcon = '🖥'
  },
  {
    order = 2,
    name = 'USB Audio Device',
    menuIcon = '🎧',
    alertIcon = '🎧'
  },
  {
    order = 3,
    name = 'AirPods',
    menuIcon = '🎧',
    alertIcon = '',
    overrides = 2
  }
})
spoon.SDCAudio:bindHotkeys({
  switchAudio = {hotkeyCombo, 'A'}
})
spoon.SDCAudio:start()
hs.hotkey.bind(hotkeyCombo, 'f13', nil, function() spoon.SDCAudio:switchAudio() end)

-- hs.loadSpoon('SDCWorkspace')
-- spoon.SDCWorkspace:bindHotkeys({
--   toggleChooser = {hotkeyCombo, 'W'}
-- })
-- spoon.SDCWorkspace:setWorkspaces({
--   {
--     title = '⌨️ Code',
--     softToggleOpen = {
--       'Google Chrome',
--       'GitHub Desktop',
--       'Atom',
--       'Terminal'
--     },
--     softToggleClose = {
--       'Tweetbot',
--       'Messages'
--     },
--     hardToggle = {}
--   },
--   {
--     title = '😁 Browse',
--     softToggleOpen = {
--       'Google Chrome',
--       'Tweetbot'
--     },
--     softToggleClose = {
--       'GitHub Desktop',
--       'Atom',
--       'Terminal'
--     },
--     hardToggle = {}
--   },
--   {
--     title = '🖌️ Design',
--     softToggleOpen = {
--       'Adobe Photoshop CC 2018',
--       'Adobe Illustrator'
--     },
--     softToggleClose = {
--       'Tweetbot',
--       'Messages'
--     },
--     hardToggle = {}
--   }
-- })

hs.loadSpoon('SDCDash')
spoon.SDCDash:setConfig(keys.dashHomeURL)
spoon.SDCDash:bindHotkeys({
  toggleWebview = {hotkeyCombo, 'f15'}
})

hs.loadSpoon('SDCReminders')
spoon.SDCReminders:bindHotkeys({
  toggleWebview = {hotkeyCombo, '9'}
})

hs.loadSpoon('SDCWeather')
spoon.SDCWeather:setConfig(keys.darksky_api_key, keys.latitude, keys.longitude)
spoon.SDCWeather:start()

hs.loadSpoon('SDCPhone')
spoon.SDCPhone:bindHotkeys({
  toggleChooser = {hotkeyCombo, 'P'}
})
spoon.SDCPhone:setShortcuts(keys.phoneNumbers)

hs.loadSpoon('SDCTimer')
spoon.SDCTimer:bindHotkeys({
  toggleTimer = {hotkeyCombo, '\\'}
})
spoon.SDCTimer:start()
hs.hotkey.bind(hotkeyCombo, 'f14', nil, function() spoon.SDCTimer:toggleTimer() end)

-- if screenClass ~= 'small' then
--   hs.loadSpoon('SDCFinance')
--   spoon.SDCFinance:setConfig({
--     currencies = {'bitcoin', 'ethereum'}
--   })
--   spoon.SDCFinance:start()
-- end

hs.loadSpoon('SDCOvercast')

-- hs.loadSpoon('SDCSpotify')
-- spoon.SDCSpotify:start()

-- hs.loadSpoon('SDCItunes')
-- spoon.SDCItunes:start()

-- New Google Calendar Event
hs.hotkey.bind(hotkeyCombo, '8', function()
	hs.urlevent.openURL('https://calendar.google.com/calendar/r/eventedit')
end)

-- Do Not Disturb toggle
-- (in Settings > Keyboard > Shortcuts)
-- {'cmd', 'alt', 'ctrl'}, f17

-- Dark Mode toggle
hs.hotkey.bind(hotkeyCombo, 'f16', function()
  hs.execute('osascript ' .. script_path() .. '/misc/darkmode-toggle.scpt')
end)

-- Force Quit Hammerspoon
-- (in Settings > Keyboard > Shortcuts)
-- {'cmd', 'alt', 'ctrl'}, -

-- Launch Hammerspoon
-- (in Settings > Keyboard > Shortcuts)
-- {'cmd', 'alt', 'ctrl'}, +

-- Mirror Display toggle
hs.hotkey.bind(hotkeyCombo, '0', function()
	hs.application.launchOrFocus('System Preferences')
	hs.timer.doAfter(1, function()
		hs.application.get('System Preferences'):selectMenuItem({'View', 'Displays'})
		hs.timer.doAfter(1, function()
			hs.window.focusedWindow():focusTab(2)
		end)
	end)
end)

-- Eject key puts computer to sleep
-- hs.eventtap.new({ hs.eventtap.event.types.NSSystemDefined }, function(event)
--	event = event:systemKey()
--	local next = next
--	if next(event) then
--		if event.key == 'EJECT' and event.down then
--			hs.caffeinate.systemSleep()
--		end
--	end
--end):start()

-- Reload Hammerspoon
hs.hotkey.bind(hotkeyCombo, '/', function()
  hs.reload()
end)
hs.alert.show('Configuration loaded.')
