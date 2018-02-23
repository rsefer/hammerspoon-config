--- === SDC Audio ===
local obj = {}
obj.__index = obj
obj.name = "SDC-Audio"

local audioSwitcherDisplay = hs.menubar.new()
local activeAudioSlug = 'headphones'
hs.audiodevice.defaultOutputDevice()

function audioSwitcherSet()

  if (hs.audiodevice.findOutputByName('USB Audio Device')) and activeAudioSlug ~= 'headphones' then
    activeAudioSlug = 'headphones'
    activeAudioName = 'USB Audio Device'
    menuTitle = '🎧'
  else
    activeAudioSlug = 'built-in'
    activeAudioName = 'Built-in Output'
    menuTitle = '🖥'
  end
  hs.audiodevice.findOutputByName(activeAudioName):setDefaultOutputDevice()
  audioSwitcherDisplay:setTitle('🔈' .. menuTitle)
  hs.alert.closeAll()
  hs.alert.show(menuTitle .. ' ' .. activeAudioName)
end

if audioSwitcherDisplay then
  audioSwitcherDisplay:setClickCallback(audioSwitcherSet)
  audioSwitcherSet()
end

hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'A', function()
  audioSwitcherSet()
end)

return obj
