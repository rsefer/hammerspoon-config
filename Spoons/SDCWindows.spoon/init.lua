--- === SDC Windows ===
local obj = {}
obj.__index = obj
obj.name = "SDCWindows"

hs.window.animationDuration = 0
hs.window.setFrameCorrectness = true
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.grid.GRIDWIDTH = 100
hs.grid.GRIDHEIGHT = 100

local computerNameFull = hs.host.localizedName()
local screenclass = 'large' -- assumes large iMac

if string.match(string.lower(computerNameFull), 'macbook') then
  screenclass = 'small'
end

require 'common'

local windowGridKeyCombo = {'cmd', 'alt', 'ctrl'}

--Size Left Half
hs.hotkey.bind(windowGridKeyCombo, 'L', function() gridset(0, 0, 50, 100) end)
-- Size Right Half
hs.hotkey.bind(windowGridKeyCombo, 'R', function() gridset(50, 0, 50, 100) end)
-- Size Full
hs.hotkey.bind(windowGridKeyCombo, 'F', function() gridset(0, 0, 100, 100) end)
-- Size Centered
hs.hotkey.bind(windowGridKeyCombo, 'C', function() gridset(12.5, 12.5, 75, 75) end)
-- Size Left 3/4ths
hs.hotkey.bind(windowGridKeyCombo, 'N', function() gridset(0, 0, 75, 100, 'three-quarters') end)
-- Size 3/4ths Centered
hs.hotkey.bind(windowGridKeyCombo, 'X', function() gridset(12.5, 0, 75, 100) end)
-- Size Right 1/4th
hs.hotkey.bind(windowGridKeyCombo, 'M', function() gridset(75, 0, 25, 100, 'one-quarter') end)
-- Size Right 1/4th Top 1/2-ish
hs.hotkey.bind(windowGridKeyCombo, ',', function() gridset(75, 0, 25, 55) end)
-- Size Right 1/4th Bottom 1/2-ish
hs.hotkey.bind(windowGridKeyCombo, '.', function() gridset(75, 60, 25, 40) end)
-- Size Half Height, Top Edge
hs.hotkey.bind(windowGridKeyCombo, 'T', function() gridset('current', 0, 'current', 50) end)
-- Size Half Height, Bottom Edge
hs.hotkey.bind(windowGridKeyCombo, 'B', function() gridset('current', 50, 'current', 50) end)
-- Move to Left Edge
hs.hotkey.bind(windowGridKeyCombo, ';', function() gridset(0, 'current', 'current', 'current') end)
-- Move to Right Edge
hs.hotkey.bind(windowGridKeyCombo, "'", function() gridset('opp', 'current', 'current', 'current') end)

hs.application.watcher.new(function(name, event, app)
  if name == 'Terminal' and event == hs.application.watcher.launched then
    if screenclass == 'small' then
      gridset(50, 0, 50, 100)
    else
      gridset(75, 0, 25, 100, 'one-quarter')
    end
  elseif name == 'TextEdit' and event == hs.application.watcher.launched then
    if screenclass == 'small' then
      gridset(50, 0, 50, 100)
    else
      gridset(75, 60, 25, 40)
    end
  elseif (name == 'Atom' or name == 'GitHub Desktop') and event == hs.application.watcher.launched then
    if screenclass == 'small' then
      gridset(0, 0, 100, 100)
    else
      gridset(0, 0, 75, 100, 'three-quarters')
    end
  elseif name == 'Google Chrome' and event == hs.application.watcher.launched then
    hs.timer.doAfter(0.25, function()
      if screenclass == 'small' then
        gridset(0, 0, 100, 100)
      else
        gridset(0, 0, 75, 100, 'three-quarters')
        hs.timer.doAfter(0.25, function()
          gridset(0, 'current', 'current', 'current')
        end)
      end
    end)
  elseif name == 'Tweetbot' and event == hs.application.watcher.launched then
    if screenclass == 'small' then
      gridset(50, 0, 50, 100)
      hs.timer.doAfter(0.25, function()
        gridset('opp', 'current', 'current', 'current')
      end)
    else
      gridset(75, 0, 25, 55)
    end
  end
end):start()

return obj
