-- To find Hammerspoon preferences:
-- 1) Run Hammerspoon from Spotlight or run `open -a Hammerspoon` in the Terminal
-- 2) Press Command + Comma

-- keys
dofile('config.lua')

-- spoons
hs.loadSpoon('SDC-Windows')
hs.loadSpoon('SDC-Audio')
hs.loadSpoon('SDC-Overcast')
hs.loadSpoon('SDC-Weather')
hs.loadSpoon('SDC-Finance')
-- hs.loadSpoon('SDC-Workspace')
-- hs.loadSpoon('SDC-Spotify')

hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, '/', function()
  hs.reload()
end)
hs.alert.show('Configuration reloaded.')
