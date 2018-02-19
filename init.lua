-- To find Hammerspoon preferences:
-- 1) Run Hammerspoon from Spotlight or run `open -a Hammerspoon` in the Terminal
-- 2) Press Command + Comma

dofile('config.lua') -- keys
dofile('windows.lua')
--dofile('workspace.lua')
dofile('audio.lua')
dofile('overcast.lua')
dofile('weather.lua')
dofile('finance.lua')
--dofile('spotify.lua')

hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, '/', function()
  hs.reload()
end)
hs.alert.show('Configuration reloaded.')
