--- === SDC Power ===
local obj = {}
obj.__index = obj
obj.name = "SDCPower"

function obj:updateBatteryMenu()
	batteryDisplayIcon = '🔌 '
	batteryDisplayString = ''
	batteryTooltipString = ''
	if hs.battery.powerSource() == 'AC Power' then
		if hs.battery.isCharged() then
			obj.batteryMenu:setTitle(nil)
			return
		end
		if hs.battery.timeToFullCharge() > 0 then
			batteryTooltipString = 'Charging (' .. minutesToClock(hs.battery.timeToFullCharge()) .. ' remaining)'
		end
	end
	batteryDisplayString = batteryDisplayString .. math.floor(hs.battery.percentage()) .. '%'
	if hs.battery.powerSource() ~= 'AC Power' then
		batteryDisplayIcon = '🔋 '
		if hs.battery.timeRemaining() > 0 then
			batteryDisplayString = batteryDisplayString .. ' ' .. minutesToClock(hs.battery.timeRemaining())
		end
	end
	obj.batteryMenu:setTitle(hs.styledtext.new(batteryDisplayIcon, { font = { size = 12 } }) .. hs.styledtext.new(batteryDisplayString, { font = { name = 'SF Mono', size = 12 } }))
	obj.batteryMenu:setTooltip(batteryTooltipString)
end

function obj:init()

	self.batteryMenu = hs.menubar:new()
	self.batteryPowerSource = hs.battery.powerSource()
	self.batteryUpdateTimer = hs.timer.doEvery(5, function()
		obj:updateBatteryMenu()
	end):stop()

	self.batteryWatcher = hs.battery.watcher.new(function()
		if isHome() and obj.batteryPowerSource ~= hs.battery.powerSource() then
			action = 'off'
			if hs.battery.powerSource() == 'AC Power' then
				action = 'on'
			end
			spoon.SDCWindows:toggleSecondaryMonitor(action)
			obj.batteryPowerSource = hs.battery.powerSource()
		end
		if obj.batteryPowerSource ~= hs.battery.powerSource() then
			obj:updateBatteryMenu()
		end
	end)

	self.caffeinateScreenWatcher = hs.caffeinate.watcher.new(function(event)
		if isHome() and hs.battery.powerSource() == 'AC Power' then
			if event == 1 or event == 2 then -- systemWillSleep (1) or systemWillPowerOff (2)
				spoon.SDCWindows:toggleSecondaryMonitor('off')
			elseif event == 0 then -- systemDidWake (0)
				spoon.SDCWindows:toggleSecondaryMonitor('on')
			end
		end
	end)

end

function obj:start()
	obj.batteryWatcher:start()
	obj:updateBatteryMenu()
	obj.batteryUpdateTimer:start()
	obj.caffeinateScreenWatcher:start()
end

function obj:stop()
	obj.batteryWatcher:stop()
	obj.batteryUpdateTimer:stop()
	obj.caffeinateScreenWatcher:stop()
end

return obj
