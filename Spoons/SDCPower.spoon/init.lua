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
			obj.batteryMenu:setIcon(nil):setTitle(nil)
			return
		end
		batteryTooltipString = 'Charging'
		if hs.battery.timeToFullCharge() > 0 then
			batteryTooltipString = batteryTooltipString .. ' (' .. minutesToClock(hs.battery.timeToFullCharge()) .. ' remaining)'
		else
			batteryTooltipString = batteryTooltipString .. ' (Calculating...)'
		end
		obj.batteryMenu:setIcon(nil)
	end

	batteryDisplayString = batteryDisplayString .. math.floor(hs.battery.percentage()) .. '%'

	if hs.battery.powerSource() ~= 'AC Power' then
		batteryDisplayIcon = ' '
		if hs.battery.timeRemaining() > 0 then
			batteryDisplayString = batteryDisplayString .. ' ' .. minutesToClock(hs.battery.timeRemaining())
		end
		obj.batteryMenu:setIcon(asciiBattery(hs.battery.percentage()), false)
	end

	obj.batteryMenu:setTitle(hs.styledtext.new(batteryDisplayIcon, { font = { size = 12 } }) .. hs.styledtext.new(batteryDisplayString, { font = { name = 'SF Mono', size = 12 } }))
	obj.batteryMenu:setTooltip(batteryTooltipString)
end

function asciiBattery(batteryPercentage)

	-- example:
	-- ....................
	-- 1==================4
	-- =a=============d...=
	-- ==.............=...=
	-- ==.............=...=
	-- ==.............=...=
	-- ==.............=...=
	-- ==.............=...=
	-- =b=============c...=
	-- 2==================3
	-- ....................

	totalInnerRows = 7
	totalCols = 20

	lastFilledCol = math.ceil(batteryPercentage / 100 * (totalCols - 2))

	asciiString = ''
	asciiString = asciiString .. '....................' .. "\n"
	asciiString = asciiString .. '1==================4' .. "\n"
	for r = 1, totalInnerRows do
		for c = 1, totalCols do
			if c == 1 or c == totalCols then
				asciiString = asciiString .. '='
			else
				if c == 2 then
					if r == 1 then
						asciiString = asciiString .. 'a'
					elseif r == totalInnerRows then
						asciiString = asciiString .. 'b'
					else
						asciiString = asciiString .. '='
					end
				elseif c == lastFilledCol then
					if r == 1 then
						asciiString = asciiString .. 'd'
					elseif r == totalInnerRows then
						asciiString = asciiString .. 'c'
					else
						asciiString = asciiString .. '='
					end
				elseif c ~= lastFilledCol then
					asciiString = asciiString .. '.'
				end
			end
		end
		asciiString = asciiString .. "\n"
	end
	asciiString = asciiString .. '2==================3' .. "\n"
	asciiString = asciiString .. '....................' .. "\n"

	batteryOutlineStrokeColor = { red = 0, green = 0, blue = 0 }
	if hs.host.interfaceStyle() == 'Dark' then
		batteryOutlineStrokeColor = { red = 1, green = 1, blue = 1 }
	end

	batteryFillColor = { red = 0.114, green = 0.725, blue = 0.329 }
	if batteryPercentage < 25 then
		batteryFillColor = { red = 1 }
	elseif batteryPercentage < 60 then
		batteryFillColor = { red = 1, green = 1 }
	end

	return hs.image.imageFromASCII(asciiString, {
		{ strokeColor = batteryOutlineStrokeColor, fillColor = { alpha = 0 } },
		{ strokeColor = { alpha = 0 }, fillColor = batteryFillColor}
	})
end

function obj:init()

	self.batteryMenu = hs.menubar:new()
	self.batteryPowerSource = hs.battery.powerSource()

	self.batteryWatcher = hs.battery.watcher.new(function()
		if isHome() and obj.batteryPowerSource ~= hs.battery.powerSource() then
			action = 'off'
			if hs.battery.powerSource() == 'AC Power' then
				action = 'on'
			end
			spoon.SDCWindows:toggleSecondaryMonitor(action)
			obj.batteryPowerSource = hs.battery.powerSource()
		end
		obj:updateBatteryMenu()
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
	obj.caffeinateScreenWatcher:start()
end

function obj:stop()
	obj.batteryWatcher:stop()
	obj.caffeinateScreenWatcher:stop()
end

return obj
