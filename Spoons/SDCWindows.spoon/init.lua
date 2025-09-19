--- === SDC Windows ===
local obj = {}
obj.__index = obj
obj.name = "SDCWindows"

function screenSizeCategory(screen, large, medium, small)
	if screen:fullFrame().w >= 1920 then
    return large
	elseif screen:fullFrame().w > 1200 then
		return medium
	end
	return small
end

function obj:getScreenMargins(screen)
	return screenSizeCategory(screen, {
		x = hs.settings.get('windowMargin').large,
		y = hs.settings.get('windowMargin').large
	}, {
		x = hs.settings.get('windowMargin').medium,
		y = hs.settings.get('windowMargin').medium
	}, {
		x = hs.settings.get('windowMargin').small,
		y = hs.settings.get('windowMargin').small
	})
end

function isCloseSize(window, size)
	errorMargin = 5
	grid = hs.grid.get(window)
	if math.abs(grid.x - size[1]) <= errorMargin and math.abs(grid.y - size[2]) <= errorMargin and math.abs(grid.w - size[3]) <= errorMargin and math.abs(grid.h - size[4]) <= errorMargin then
		return true
	end
	return false
end

function obj:getClosestPresetSize(window)
	for k, size in pairs(hs.settings.get('windowSizes')) do
		if size[1] then -- checks for size vs sub-key
			if isCloseSize(window, size) then
				return size
			end
		else
			for k2, size2 in pairs(size) do
				if size2[1] then
					if isCloseSize(window, size2) then
						return size2
					end
				end
			end
		end
	end
	return nil
end

function obj:moveWindowIfCloseToPreset(window)
	suggestedSize = obj:getClosestPresetSize(window)
	if suggestedSize ~= nil then
		obj:windowMove(window, window:screen(), suggestedSize)
	end
end

function obj:appMove(appName, screen, size)
	if appName ~= nil then
		app = hs.application.get(appName)

		-- if window movement/resetting is not working, change the offending app name to the app bundle id in lib/spoons.lua
		-- Obtain app bundle id: osascript -e 'id of app "AppName"'
		-- print(hs.inspect(appName))
		if app ~= nil then
			if (contains(obj.ignoreTitles, app:title())) then
				return
			end
			if #app:allWindows() > 0 then
				for x, window in ipairs(app:allWindows()) do
					-- print(hs.inspect(window))
					obj:windowMove(window, screen, size)
				end
			end
		end
	end
end

function obj:windowMove(window, screen, size)
	if not window then
		window = hs.window.focusedWindow()
	end
	if not window then
		-- occurs when there are no focusable windows (usually when all apps are hidden)
		return
	end
	local workingScreen = window:screen()
	if screen ~= nil then
		workingScreen = screen
	end
	hs.grid.setMargins(screenSizeCategory(workingScreen, {
		x = hs.settings.get('windowMargin').large,
		y = hs.settings.get('windowMargin').large
	}, {
		x = hs.settings.get('windowMargin').medium,
		y = hs.settings.get('windowMargin').medium
	}, {
		x = hs.settings.get('windowMargin').small,
		y = hs.settings.get('windowMargin').small
	}))

	if window:application():name() and contains(obj.finickyApps, window:application():name()) then
		window:moveToScreen(workingScreen)
		cell = hs.grid.getCell(size, workingScreen)
		margin = screenSizeCategory(workingScreen, {
			x = hs.settings.get('windowMargin').large,
			y = hs.settings.get('windowMargin').large
		}, {
			x = hs.settings.get('windowMargin').medium,
			y = hs.settings.get('windowMargin').medium
		}, {
			x = hs.settings.get('windowMargin').small,
			y = hs.settings.get('windowMargin').small
		})
		newCoords = {
			x1 = cell.x + (margin.x / 2),
			y1 = cell.y + margin.y
		}
		newCoords.x2 = cell.w + cell.x - margin.x
		newCoords.y2 = cell.h + cell.y - (margin.y / 2)

		localCoords = workingScreen:absoluteToLocal(cell)
		if window:application():name() == 'Terminal' then
			terminalFontSize = 14
			if contains(hs.settings.get('tertiaryMonitorNames'), workingScreen:id()) then
				newCoords = {
					x1 = cell.x + localCoords.x + margin.x,
					y1 = localCoords.y + margin.y
				}
				newCoords.x2 = newCoords.x1 + localCoords.w - (margin.x * 2)
				newCoords.y2 = newCoords.y1 + localCoords.h - (margin.y * 2)
				terminalFontSize = 20
			elseif newCoords.y1 > 0 and workingScreen:name() == hs.settings.get('primaryMonitorName') and (hs.settings.get('deskSetup') == 'desk' or hs.settings.get('deskSetup') == 'deskWithiPad') then
				adjustmentY = newCoords.y1 - margin.y
				newCoords.y1 = newCoords.y1 - adjustmentY
				newCoords.y2 = newCoords.y2 - adjustmentY
			end
			hs.osascript.applescript('tell application "' .. window:application():name() .. '" to set the font size of window 1 to ' .. terminalFontSize)
		end
		asString = [[
			tell application "]] .. window:application():name() .. [["
				set the bounds of window 1 to {]] .. newCoords.x1 .. [[, ]] .. newCoords.y1 .. [[, ]] .. newCoords.x2 .. [[, ]] .. newCoords.y2 .. [[}
			end tell
		]]
		hs.osascript.applescript(asString)
	else
		hs.grid.set(window, size, workingScreen)
	end

end

function obj:toggleDock()
	hs.osascript.applescript('tell application "System Events" to tell dock preferences to set autohide to not autohide')
end

function obj:resetAllApps()
	hs.alert.show('Desk Setup: ' .. hs.settings.get('deskSetupLabel'), { atScreenEdge = 1 })
	for i, item in ipairs(obj.windowLayout) do
		for a, app in ipairs(item.apps) do
			obj:appMove(app, screenChooser(item.screens), windowSizeChooser(item.sizes))
		end
	end
end

function obj:bindHotkeys(mapping)
  hs.spoons.bindHotkeysToSpec({
		resetWindows = function()
			obj:resetAllApps()
		end,
		sizeLeftHalf = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').halves.left)
		end,
		sizeRightHalf = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').halves.right)
		end,
		sizeFull = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').full)
		end,
		sizeCentered = function()
			if hs.window.focusedWindow():title() == 'FaceTime' then
				hs.window.focusedWindow():centerOnScreen()
			else
				obj:windowMove(nil, nil, hs.settings.get('windowSizes').center)
			end
		end,
		sizeLeft23rds = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').thirds.left2)
		end,
		sizeLeft13rd = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').thirds.left)
		end,
		sizeLeft13rdTopHalfish = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').thirds.leftTop)
		end,
		sizeLeft13rdBottomHalfish = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').thirds.leftBottom)
		end,
		sizeRight23rds = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').thirds.right2)
		end,
		sizeRight13rd = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').thirds.right)
		end,
		sizeRight13rdTopHalfish = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').thirds.rightTop)
		end,
		sizeRight13rdBottomHalfish = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').thirds.rightBottom)
		end,
		sizeHalfHeightTopEdge = function()
			winGrid = hs.grid.get(hs.window:focusedWindow())
			obj:windowMove(nil, nil, {winGrid.x, 0, winGrid.w + 1, hs.grid.getGrid().h / 2})
		end,
		sizeHalfHeightBottomEdge = function()
			winGrid = hs.grid.get(hs.window:focusedWindow())
			obj:windowMove(nil, nil, {winGrid.x, hs.grid.getGrid().h / 2, winGrid.w + 1, hs.grid.getGrid().h / 2})
		end,
		sizeQ1 = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').quadrants.one)
		end,
		sizeQ2 = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').quadrants.two)
		end,
		sizeQ3 = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').quadrants.three)
		end,
		sizeQ4 = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').quadrants.four)
		end,
		moveLeftEdge = function()
			winGrid = hs.grid.get(hs.window:focusedWindow())
			obj:windowMove(nil, nil, {0, winGrid.y, winGrid.w + 1, winGrid.h + 1})
		end,
		moveRightEdge = function()
			winGrid = hs.grid.get(hs.window:focusedWindow())
			obj:windowMove(nil, nil, {hs.grid.getGrid().w - winGrid.w - 1, winGrid.y, winGrid.w + 1, winGrid.h + 1})
		end,
		moveWindowRightScreen = function()
			hs.window.focusedWindow():moveOneScreenEast(false, true)
		end,
		moveWindowLeftScreen = function()
			hs.window.focusedWindow():moveOneScreenWest(false, true)
		end,
		moveWindowUpScreen = function()
			hs.window.focusedWindow():moveOneScreenNorth(false, true)
		end,
		moveWindowDownScreen = function()
			hs.window.focusedWindow():moveOneScreenSouth(false, true)
		end
  }, mapping)
end

function obj:handleScreenChange()
	screenNames = hs.fnutils.imap(hs.screen.allScreens(), function(screen)
		if not screen:name() and screen:id() == hs.settings.get('tertiaryMonitorNames') then return 'iPad' end
		return screen:name()
	end)
	existingDeskSetup = hs.settings.get('deskSetup')
	if contains(screenNames, hs.settings.get('secondaryMonitorName')) then
		hs.settings.set('deskSizeClass', 'large')
		if contains(screenNames, 'iPad') or contains(screenNames, 'Sidecar Display (AirPlay)') then
			hs.settings.set('deskSetup', 'deskWithiPad')
		else
			hs.settings.set('deskSetup', 'desk')
		end
		for i = 1, 16, 1 do
			hs.eventtap.event.newSystemKeyEvent('ILLUMINATION_DOWN', true):post()
			hs.eventtap.event.newSystemKeyEvent('ILLUMINATION_DOWN', false):post()
		end
	else
		hs.settings.set('deskSizeClass', 'small')
		if contains(screenNames, 'iPad')  or contains(screenNames, 'Sidecar Display (AirPlay)') or contains(screenNames, 'RTKFHD') then
			hs.settings.set('deskSetup', 'laptopWithSide')
		else
			hs.settings.set('deskSetup', 'laptop')
		end
	end
end

function obj:getAppLayoutSettings(appName)
	for k, ao in ipairs(obj.windowLayout) do
		if contains(ao.apps, appName) then
			return ao
		end
	end
	return nil
end

function obj:init()
	self.screenWatcher = nil
	self.applicationWatcher = nil
	if not self.finickyApps then
		self.finickyApps = {}
	end
end

function obj:start()

	self:handleScreenChange()

	hs.urlevent.bind('resetAllApps', function(event, params)
		self:resetAllApps()
	end)

	self.screenWatcher = hs.screen.watcher.newWithActiveScreen(function(activeScreenChange)
		if activeScreenChange then return end

		resetGrid()
		hs.timer.doAfter(1, function()
			self:handleScreenChange()
		end)

	end):start()

	self.applicationWatcher = hs.application.watcher.new(function(name, event, app)
		if event == 5 and name == 'Finder' and #app:allWindows() == 0 then
			hs.timer.doAfter(0.25, function()
				obj:windowMove(hs.window.focusedWindow(), nil, hs.settings.get('windowSizes').center)
			end)
		elseif event == 1 or event == hs.application.watcher.launched then
			for k, ao in ipairs(self.windowLayout) do
				if contains(ao.apps, name) then
					if #app:allWindows() ~= 1 or (#app:allWindows() == 1 and app:allWindows()[1]:title() ~= 'Open') then
						hs.timer.doAfter(2, function()
							obj:appMove(name, screenChooser(ao.screens), windowSizeChooser(ao.sizes))
						end)
						break
					end
				end
			end
		end
  end):start()

  return self
end

function obj:stop()
	self.screenWatcher:stop()
  self.applicationWatcher:stop()
  return self
end

return obj
