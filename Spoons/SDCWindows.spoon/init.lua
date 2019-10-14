--- === SDC Windows ===
local obj = {}
obj.__index = obj
obj.name = "SDCWindows"

function obj:appFrameSet(layout, app)
	if app == nil then
		app = hs.application.frontmostApplication()
	end
	hs.layout.apply({
		{
			app:name(),
			nil,
			app:focusedWindow():screen(),
			layout
		}
	})
end

function obj:gridset(x1, y1, w1, h1, nickname, app)
  local win = nil
  if app ~= nil then
    windows = app:allWindows()
  else
    windows = { hs.window.focusedWindow() }
  end
  if windows ~= nil then
		for k, win in ipairs(windows) do
	    local currentRect = hs.grid.get(win)
			local monitorName = win:screen():name()
	    if nickname ~= nil and hs.settings.get('secondaryMonitorName') ~= nil and hs.settings.get('secondaryMonitorName') == monitorName then
	      if nickname == '34ths' then
	        x1 = 27
	      elseif nickname == '14th' then
	        x1 = 0
	      end
	    end
	    if x1 == 'current' then
	      x2 = currentRect.x
	    elseif x1 == 'opp' then
	      x2 = 100 - currentRect.w
	    else
	      x2 = x1
	    end
	    if y1 == 'current' then
	      y2 = currentRect.y
	    else
	      y2 = y1
	    end
	    if w1 == 'current' then
	      w2 = currentRect.w
	    else
	      w2 = w1
	    end
	    if h1 == 'current' then
	      h2 = currentRect.h
	    else
	      h2 = h1
	    end
	    hs.grid.set(
	      win,
	      { x = x2, y = y2, w = w2, h = h2 },
	      win:screen()
	    )
	  end
	end
end

function obj:bindHotkeys(mapping)
  local def = {
		resetWindows = function()
			hs.layout.apply(obj.windowLayout)
		end,
		sizeLeftHalf = function()
			obj:appFrameSet(hs.layout.left50)
		end,
		sizeRightHalf = function()
			obj:appFrameSet(hs.layout.right50)
		end,
		sizeFull = function()
			obj:appFrameSet(hs.layout.maximized)
		end,
		sizeCentered = function()
			obj:appFrameSet(hs.geometry.unitrect(0.125, 0.125, 0.75, 0.75))
		end,
		sizeLeft34ths = function()
			obj:appFrameSet(hs.geometry.unitrect(0.00, 0.00, 0.73, 1.00))
		end,
		size34thsCentered = function()
			obj:appFrameSet(hs.geometry.unitrect(0.125, 0.00, 0.73, 1.00))
		end,
		sizeRight14th = function()
			obj:appFrameSet(hs.geometry.unitrect(0.73, 0.00, 0.27, 1.00))
		end,
		sizeRight14thTopHalfish = function()
			obj:appFrameSet(hs.geometry.unitrect(0.73, 0.00, 0.27, 0.55))
		end,
		sizeRight14thBottomHalfish = function()
			obj:appFrameSet(hs.geometry.unitrect(0.73, 0.60, 0.27, 0.40))
		end,
		sizeHalfHeightTopEdge = function()
			win = hs.window:focusedWindow()
			win:setFrame(hs.geometry.rect(win:frame().x, 0.00, win:frame().w, win:screen():frame().h / 2))
		end,
		sizeHalfHeightBottomEdge = function()
			win = hs.window:focusedWindow()
			win:setFrame(hs.geometry.rect(win:frame().x, win:screen():fullFrame().h / 2, win:frame().w, win:screen():fullFrame().h / 2))
		end,
		moveLeftEdge = function()
			win = hs.window:focusedWindow()
			win:setFrame(hs.geometry.rect(win:screen():frame().x, win:frame().y, win:frame().w, win:frame().h))
		end,
		moveRightEdge = function()
			win = hs.window:focusedWindow()
			win:setFrame(hs.geometry.rect(win:screen():fullFrame().w - win:frame().w, win:frame().y, win:frame().w, win:frame().h))
		end
  }
  hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:init()

  hs.window.animationDuration = 0
  hs.window.setFrameCorrectness = true
  hs.grid.MARGINX = 0
  hs.grid.MARGINY = 0
  hs.grid.GRIDWIDTH = 1
  hs.grid.GRIDHEIGHT = 1

	self.applicationWatcher = nil

end

function obj:start()

	self.applicationWatcher = hs.application.watcher.new(function(name, event, app)
		if event == 1 or event == hs.application.watcher.launched then
			for k, watchedApp in ipairs(self.watchedApps) do
        if contains(watchedApp.names, tostring(name)) then
          standardDelay = 0.5
          delay = 0
          if watchedApp.delay ~= nil then
            if watchedApp.delay == true then
              delay = standardDelay
            elseif watchedApp.delay > 0 then
              delay = watchedApp.delay
            end
          end
          hs.timer.doAfter(delay, function()
						local appDimensions = watchedApp.large
						if hs.settings.get('screenClass') == 'small' or watchedApp.withMultipleMonitors == hs.settings.get('tertiaryMonitorName') then
							appDimensions = watchedApp.small
						end

						screenTarget = hs.screen.primaryScreen()
						if watchedApp.withMultipleMonitors == hs.settings.get('tertiaryMonitorName') then
							screenTarget = hs.screen.find(hs.settings.get('tertiaryMonitorName'))
						elseif watchedApp.withMultipleMonitors == hs.settings.get('secondaryMonitorName') then
							screenTarget = hs.screen.find(hs.settings.get('secondaryMonitorName'))
						end
						for k2, window in ipairs(app:allWindows()) do
							window:moveToScreen(screenTarget)
						end

            obj:gridset(appDimensions.x1, appDimensions.y1, appDimensions.w1, appDimensions.h1, appDimensions.nickname, app)
            if appDimensions.doAfter then
              obj:gridset(appDimensions.doAfter.x1, appDimensions.doAfter.y1, appDimensions.doAfter.w1, appDimensions.doAfter.h1, appDimensions.doAfter.nickname)
            end
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
