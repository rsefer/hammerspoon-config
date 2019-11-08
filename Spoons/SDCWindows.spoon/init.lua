--- === SDC Windows ===
local obj = {}
obj.__index = obj
obj.name = "SDCWindows"

function obj:appMove(appName, screen, size)
	if appName ~= nil then
		app = hs.application.get(appName)
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
	hs.grid.set(window, size, workingScreen)
end

function obj:resetAllApps()
	for i, item in ipairs(obj.windowLayout) do
		obj:appMove(item[1], item[2], item[3])
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
		sizeLeft23rds = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').thirds.left2)
		end,
		sizeRight13rd = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').thirds.right)
		end,
		sizeRight13rdTopHalfish = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').thirds.leftTop)
		end,
		sizeRight13rdBottomHalfish = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').thirds.leftBottom)
		end,
		sizeHalfHeightTopEdge = function()
			winGrid = hs.grid.get(hs.window:focusedWindow())
			obj:windowMove(nil, nil, gr(winGrid.x, 0, winGrid.w + 1, hs.grid.getGrid().h / 2))
		end,
		sizeHalfHeightBottomEdge = function()
			winGrid = hs.grid.get(hs.window:focusedWindow())
			obj:windowMove(nil, nil, gr(winGrid.x, hs.grid.getGrid().h / 2, winGrid.w + 1, hs.grid.getGrid().h / 2))
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
			obj:windowMove(nil, nil, gr(0, winGrid.y, winGrid.w + 1, winGrid.h + 1))
		end,
		moveRightEdge = function()
			winGrid = hs.grid.get(hs.window:focusedWindow())
			obj:windowMove(nil, nil, gr(hs.grid.getGrid().w - winGrid.w - 1, winGrid.y, winGrid.w + 1, winGrid.h + 1))
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
		if event == 1 or event == hs.application.watcher.launched then
			for k, ao in ipairs(self.windowLayout) do
				if name == ao[1] then
					hs.timer.doAfter(2, function()
						obj:appMove(ao[1], ao[2], ao[3])
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
