-- To find Hammerspoon preferences:
-- 1) Run Hammerspoon from Spotlight or run `open -a Hammerspoon` in the Terminal
-- 2) Press Command + Comma

-- keys
dofile('config.lua')

-- spoons
hs.loadSpoon('SDCWindows')
hs.loadSpoon('SDCAudio'):bindHotkeys({
  switchAudio = {{'cmd', 'alt', 'ctrl'}, 'A'}
})
hs.loadSpoon('SDCOvercast')
print(keys.latitude)
hs.loadSpoon('SDCWeather'):start(keys.darksky_api_key, keys.latitude, keys.longitude)
hs.loadSpoon('SDCFinance')
-- hs.loadSpoon('SDCWorkspace')
-- hs.loadSpoon('SDCSpotify')

hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, '/', function()
  hs.reload()
end)
hs.alert.show('Configuration reloaded.')
