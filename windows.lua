-- Window Management
hs.window.animationDuration = 0
hs.window.setFrameCorrectness = true
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.grid.GRIDWIDTH = 100
hs.grid.GRIDHEIGHT = 100

require 'common'

local windowGridKeyCombo = {'cmd', 'alt', 'ctrl'}

-- Size Left Half
hs.hotkey.bind(windowGridKeyCombo, 'L', gridset(0, 0, 50, 100))
-- Size Right Half
hs.hotkey.bind(windowGridKeyCombo, 'R', gridset(50, 0, 50, 100))
-- Size Full
hs.hotkey.bind(windowGridKeyCombo, 'F', gridset(0, 0, 100, 100))
-- Size Centered
hs.hotkey.bind(windowGridKeyCombo, 'C', gridset(12.5, 12.5, 75, 75))
-- Size Left 3/4ths
hs.hotkey.bind(windowGridKeyCombo, 'N', gridset(0, 0, 75, 100, 'three-quarters'))
-- Size 3/4ths Centered
hs.hotkey.bind(windowGridKeyCombo, 'X', gridset(12.5, 0, 75, 100))
-- Size Right 1/4th
hs.hotkey.bind(windowGridKeyCombo, 'M', gridset(75, 0, 25, 100, 'one-quarter'))
-- Size Right 1/4th Top 1/2-ish
hs.hotkey.bind(windowGridKeyCombo, ',', gridset(75, 0, 25, 55))
-- Size Right 1/4th Bottom 1/2-ish
hs.hotkey.bind(windowGridKeyCombo, '.', gridset(75, 60, 25, 40))
-- Size Half Height, Top Edge
hs.hotkey.bind(windowGridKeyCombo, 'T', gridset('current', 0, 'current', 50))
-- Size Half Height, Bottom Edge
hs.hotkey.bind(windowGridKeyCombo, 'B', gridset('current', 50, 'current', 50))
-- Move to Left Edge
hs.hotkey.bind(windowGridKeyCombo, ';', gridset(0, 'current', 'current', 'current'))
-- Move to Right Edge
hs.hotkey.bind(windowGridKeyCombo, "'", gridset('opp', 'current', 'current', 'current'))
