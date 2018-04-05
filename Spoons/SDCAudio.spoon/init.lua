--- === SDC Audio ===
local obj = {}
obj.__index = obj
obj.name = "SDCAudio"

function directAudioSource(direct)
  if obj.devices[direct] ~= nil then
    return obj.devices[direct]
  else
    return nil
  end
end

function nextAudioSource(current)
  newSource = nil
  workingStart = current - 1
  if workingStart < 1 then
    workingStart = obj.devicesCount
  end
  for i = workingStart, 1, -1 do
    thisDevice = obj.devices[i]
    if hs.audiodevice.findOutputByName(thisDevice.name) and (obj.devices[current].overrides == nil or obj.devices[current].overrides ~= i) then
      return thisDevice
    end
  end
  return newSource
end

function obj:switchAudio(direct)

  if direct ~= nil then
    newSource = directAudioSource(direct)
  else
    newSource = nextAudioSource(obj.activeOrder)
  end

  if newSource ~= nil then
    obj.activeAudioName = newSource.name
    obj.activeTitle = newSource.icon
    obj.activeOrder = newSource.order
    hs.audiodevice.findOutputByName(obj.activeAudioName):setDefaultOutputDevice()
    obj.audioSwitcherMenu:setTitle('🔈' .. obj.activeTitle)
    hs.alert.closeAll()
    hs.alert.show(obj.activeTitle .. ' ' .. obj.activeAudioName)
    obj.activeAudioName = newSource.name
  end

  return self

end

function obj:setConfig(devices)
  obj.devices = devices
  count = 0
  for i, v in pairs(devices) do
    count = count + 1
  end
  obj.devicesCount = count
end

function obj:bindHotkeys(mapping)
  local def = {
    switchAudio = hs.fnutils.partial(self.switchAudio, self)
  }
  hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:init()
  --
end

function obj:start()
  self.audioSwitcherMenu = hs.menubar.new()
    :setTitle('🔈🖥')
    :setClickCallback(obj.switchAudio)
  self:switchAudio(1)
end

return obj
