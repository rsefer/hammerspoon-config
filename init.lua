-- To find Hammerspoon preferences:
-- 1) Run Hammerspoon from Spotlight or run `open -a Hammerspoon` in the Terminal
-- 2) Press Command + Comma

dofile('config.lua')

local hotkeyCombo = {'cmd', 'alt', 'ctrl'}
local computerName = hs.host.localizedName()
local screenClass = 'large' -- assumes large iMac
if string.match(string.lower(computerName), 'macbook') then
  screenClass = 'small'
end

-- Spoons

hs.loadSpoon('SDCWindows')
spoon.SDCWindows:bindHotkeys({
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
spoon.SDCWindows:setSecondaryMonitor('DELL P2415Q')
spoon.SDCWindows:setWatchedApps({
  {
    names = {'Terminal'},
    small = { x1 = 50, y1 = 0, w1 = 50, h1 = 100 },
    large = { x1 = 75, y1 = 0, w1 = 25, h1 = 100, nickname = '14th' }
  },
  {
    names = {'TextEdit'},
    small = { x1 = 50, y1 = 0, w1 = 50, h1 = 100 },
    large = { x1 = 75, y1 = 60, w1 = 25, h1 = 40 }
  },
  {
    names = {'Atom', 'GitHub Desktop'},
    delay = 1,
    small = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 },
    large = { x1 = 0, y1 = 0, w1 = 75, h1 = 100, nickname = '34ths' }
  },
  {
    names = {'Google Chrome'},
    delay = true,
    small = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 },
    large = { x1 = 0, y1 = 0, w1 = 75, h1 = 100, nickname = '34ths' }
  },
  {
    names = {'Tweetbot'},
    small = { x1 = 50, y1 = 0, w1 = 50, h1 = 100, doAfter = {
      x1 = 'opp', y1 = 'current', w1 = 'current', h1 = 'current'
    } },
    large = { x1 = 75, y1 = 0, w1 = 25, h1 = 55 }
  }
})
spoon.SDCWindows:start()

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

-- Reload
hs.hotkey.bind(hotkeyCombo, '/', function()
  hs.reload()
end)
hs.alert.show('Configuration loaded.')
