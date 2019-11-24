--- === SDC Windows ===
local obj = {}
obj.__index = obj
obj.name = "SDCWindows"

function screenSizeCategory(screen, large, medium, small)
	if screen:fullFrame().w > 1920 then
    return large
	elseif screen:fullFrame().w > 1440 then
		return medium
	end
	return small
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
		if app == nil then
			app = hs.application.find(appName)
		end
	end
	if app then
		for x, window in ipairs(app:allWindows()) do
			obj:windowMove(window, screen, size)
		end
	end
end

function obj:windowMove(window, screen, size)
	if window == nil then
		window = hs.window:focusedWindow()
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

	local finickyApps = {
		'Terminal'
	}

	if contains(finickyApps, window:application():name()) then
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
		hs.osascript.applescript([[
			tell application "]] .. window:application():name() .. [["
				set the bounds of the first window to {]] .. (cell.x + margin.x) .. [[, ]] .. (cell.y + margin.y) .. [[, ]] .. (cell.w + cell.x - (margin.x / 2)) .. [[, ]] .. (cell.h + cell.y - (margin.y / 2)) .. [[}
			end tell
		]])
	else
		hs.grid.set(window, size, workingScreen)
	end

end

function obj:resetAllApps()
	for i, item in ipairs(obj.windowLayout) do
		for a, app in ipairs(item.apps) do
			obj:appMove(app, item.screen, item.size)
		end
	end
end

function obj:bindHotkeys(mapping)
  local def = {
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
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').center)
		end,
		sizeRight23rds = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').thirds.right2)
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
  }
  hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:init()
	self.applicationWatcher = nil
end

function obj:start()

	self.applicationWatcher = hs.application.watcher.new(function(name, event, app)
		if event == 5 and name == 'Finder' and tablelength(app:allWindows()) == 0 then
			hs.timer.doAfter(0.25, function()
				obj:windowMove(hs.window.focusedWindow(), nil, hs.settings.get('windowSizes').center)
			end)
		elseif event == 1 or event == hs.application.watcher.launched then
			for k, ao in ipairs(self.windowLayout) do
				if contains(ao.apps, name) then
					hs.timer.doAfter(2, function()
						obj:appMove(name, ao.screen, ao.size)
					end)
					break
				end
			end
		end
  end):start()

  return self
end

function obj:stop()
  self.applicationWatcher:stop()
  return self
end

return obj
