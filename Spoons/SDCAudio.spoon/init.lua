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
    workingStart = #obj.devices
  end
	for i = workingStart, 1, -1 do
		thisDevice = obj.devices[i]
		if hs.audiodevice.findOutputByName(thisDevice.name) and (not obj.devices[current].overrides or obj.devices[current].overrides ~= i) then
      return thisDevice
    end
	end
  return newSource
end

function obj:switchAudio(direct)
  if direct ~= nil then
    newSource = directAudioSource(direct)
	else
    newSource = nextAudioSource(obj.activeOrder or 1)
	end

	if newSource ~= nil then
    hs.audiodevice.findOutputByName(newSource.name):setDefaultOutputDevice()
  end

  return self

end

function obj:getSourceByName(name)
	for x, device in ipairs(obj.devices) do
		if name == device['name'] then
			return device
		end
	end
	return nil
end

function obj:recordSource(newSource)
	if not newSource then return end
	obj.activeAudioName = newSource.name
	obj.activeMenuTitle = newSource.menuIcon
	obj.activeAlertTitle = newSource.alertIcon
	obj.activeOrder = newSource.order
	obj.audioSwitcherMenu:setTitle('🔈' .. obj.activeMenuTitle)
	for i, alert in pairs(obj.alerts) do
		hs.alert.closeSpecific(alert)
	end
	obj.alerts = {}
	table.insert(obj.alerts, hs.alert.show(obj.activeAlertTitle .. ' ' .. obj.activeAudioName))
end

function obj:bindHotkeys(mapping)
  hs.spoons.bindHotkeysToSpec({
    switchAudio = hs.fnutils.partial(self.switchAudio, self)
  }, mapping)
end

function obj:init()
	obj.alerts = {}
end

function obj:start()

	hs.audiodevice.watcher.setCallback(function(action)
		if action == 'dev#' or action == 'dOut' or action == 'sOut' then
			obj:recordSource(obj:getSourceByName(hs.audiodevice.defaultOutputDevice():name()))
		end
	end)
	hs.audiodevice.watcher.start()

  self.audioSwitcherMenu = hs.menubar.new()
		:setClickCallback(obj.switchAudio)
	self:recordSource(self:getSourceByName(hs.audiodevice.defaultOutputDevice():name()))

end

return obj
