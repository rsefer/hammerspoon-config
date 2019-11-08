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

function obj:bindHotkeys(mapping)
  local def = {
		resetWindows = function()
			for i, item in ipairs(obj.windowLayout) do
				obj:appMove(item[1], item[2], item[3])
			end
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
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').thirds.rightTop)
		end,
		sizeRight13rdBottomHalfish = function()
			obj:windowMove(nil, nil, hs.settings.get('windowSizes').thirds.rightBottom)
		end,
		sizeHalfHeightTopEdge = function()
			win = hs.window:focusedWindow()
			winGridFrame = hs.grid.getCell(hs.grid.get(win), win:screen())
			screenFrame = win:screen():frame()
			win:setFrame(hs.geometry(winGridFrame.x, screenFrame.y + hs.settings.get('windowSizes').margin, winGridFrame.w, (screenFrame.h - (hs.settings.get('windowSizes').margin * 3)) / 2))
		end,
		sizeHalfHeightBottomEdge = function()
			win = hs.window:focusedWindow()
			winGridFrame = hs.grid.getCell(hs.grid.get(win), win:screen())
			screenFrame = win:screen():frame()
			win:setFrame(hs.geometry(winGridFrame.x, screenFrame.h + screenFrame.y - hs.settings.get('windowSizes').margin - winGridFrame.h, winGridFrame.w, (screenFrame.h - (hs.settings.get('windowSizes').margin * 3)) / 2))
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
			win = hs.window:focusedWindow()
			winGridFrame = hs.grid.getCell(hs.grid.get(win), win:screen())
			screenFrame = win:screen():frame()
			win:setFrame(hs.geometry(screenFrame.x + hs.settings.get('windowSizes').margin, winGridFrame.y, winGridFrame.w, winGridFrame.h))
		end,
		moveRightEdge = function()
			win = hs.window:focusedWindow()
			winGridFrame = hs.grid.getCell(hs.grid.get(win), win:screen())
			screenFrame = win:screen():frame()
			win:setFrame(hs.geometry(screenFrame.x + screenFrame.w - hs.settings.get('windowSizes').margin -  winGridFrame.w, winGridFrame.y, winGridFrame.w, winGridFrame.h))
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
						hs.layout.apply({ ao })
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
