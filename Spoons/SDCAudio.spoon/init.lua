--- === SDC Audio ===
local obj = {}
obj.__index = obj
obj.name = "SDCAudio"

function obj:switchAudio()

  if (hs.audiodevice.findOutputByName('Built-in Output')) and obj.activeAudioSlug ~= 'built-in' then
    obj.activeAudioSlug = 'built-in'
    obj.activeAudioName = 'Built-in Output'
    obj.activeTitle = '🖥'
  elseif hs.audiodevice.findOutputByName('USB Audio Device') then
    obj.activeAudioSlug = 'headphones'
    obj.activeAudioName = 'USB Audio Device'
    obj.activeTitle = '🎧'
  end

  hs.audiodevice.findOutputByName(obj.activeAudioName):setDefaultOutputDevice()
  obj.audioSwitcherMenu:setTitle('🔈' .. obj.activeTitle)
  hs.alert.closeAll()
  hs.alert.show(obj.activeTitle .. ' ' .. obj.activeAudioName)

  return self

end

function obj:bindHotkeys(mapping)
  local def = {
    switchAudio = hs.fnutils.partial(self.switchAudio, self)
  }
  hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:init()
  self.audioSwitcherMenu = hs.menubar.new()
    :setTitle('🔈🖥')
    :setClickCallback(obj.switchAudio)
  self.activeAudioSlug = ''
  self:switchAudio()
end

return obj
