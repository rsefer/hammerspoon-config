--- === SDC Timer ===
local obj = {}
obj.__index = obj
obj.name = "SDCTimer"
obj.timeIntervalSeconds = 15 * 60
obj.alertStyle = {
	atScreenEdge = 1
}

local iconBlack = hs.image.imageFromPath(hs.spoons.scriptPath() .. 'images/timer_black.pdf'):setSize({ w = 14.0, h = 14.0 })
local iconGreen = hs.image.imageFromPath(hs.spoons.scriptPath() .. 'images/timer_green.pdf'):setSize({ w = 14.0, h = 14.0 })

function timeString()
	local timeString = ''
	local remainingTime = obj.timeAccrued
	local timeAccruedHoursR = math.floor(obj.timeAccrued / 60 / 60)
	if (timeAccruedHoursR > 0) then
		timeString = timeAccruedHoursR .. ' hour'
		if timeAccruedHoursR ~= 1 then
			timeString = timeString .. 's'
		end
		remainingTime = remainingTime - (timeAccruedHoursR * 60 * 60)
	end
	local timeAccruedMinutesR = math.ceil(remainingTime / 60)
	if timeAccruedHoursR > 0 and timeAccruedMinutesR > 0 then
		timeString = timeString .. ', '
	end
	timeString = timeString .. timeAccruedMinutesR .. ' minute'
	if timeAccruedMinutesR ~= 1 then
		timeString = timeString .. 's'
	end
	return timeString
end

function updateTimeElapsedAlert()
	hs.alert.show(timeString(), obj.alertStyle, 9)
end

function updateTimeElapsed()
	obj.timeAccrued = os.time() - obj.timeStart
end

function obj:toggleTimer()
  if obj.timerMain and obj.timerMain:running() then
    obj:stop()
  else
    obj:timerReset()
		obj:start()
  end
end

function obj:timerReset()
	obj.timeAccrued = 0
	obj.timeStart = nil
	obj.timerMain = hs.timer.doEvery(obj.timeIntervalSeconds, function()
		updateTimeElapsedAlert()
	end):stop()
	obj.timerCounter = hs.timer.doEvery(60, function()
		updateTimeElapsed()
	end):stop()
end

function obj:bindHotkeys(mapping)
  local def = {
    toggleTimer = hs.fnutils.partial(self.toggleTimer, self)
  }
  hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:init()
	self.logger = hs.logger.new(self.name, 'info')
	self.timerMenu = hs.menubar.new()
		:setClickCallback(obj.toggleTimer)
		:setIcon(iconBlack, true)
	self.timerMain = nil
	self.timerCounter = nil
end

function obj:start()
	obj:timerReset()
	local time = os.date('*t')
	obj.timeStart = os.time()
	obj.timerMain:start()
	obj.timerCounter:start()
	obj.timerMenu:setIcon(iconGreen, false)
	local timeStringStart = 'Timer started at ' .. os.date('%I:%M%p')
	hs.alert.show(timeStringStart, obj.alertStyle, 5)
	obj.logger:i(timeStringStart)
end

function obj:stop()
	obj.timerMain:stop()
	obj.timerCounter:stop()
	obj.timerMenu:setIcon(iconBlack, true)
	local timeStringEnd = 'Timer stopped. Total time: ' .. timeString()
	hs.alert.show(timeStringEnd, obj.alertStyle, 15)
	obj.logger:i(timeStringEnd)
	obj:timerReset()
end

return obj
