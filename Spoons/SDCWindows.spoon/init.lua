--- === SDC Windows ===
local obj = {}
obj.__index = obj
obj.name = "SDCWindows"

local function contains(table, val)
  for i = 1, #table do
    if table[i] == val then
      return true
    end
  end
  return false
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
	    if nickname ~= nil and obj.secondaryMonitorName ~= nil and obj.secondaryMonitorName == monitorName then
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

function obj:resetWindows()
	if obj.secondaryMonitorName ~= nil or obj.tertiaryMonitorName ~= nil then
		for k, appGroup in ipairs(obj.watchedApps) do
			for k2, name in ipairs(appGroup.names) do
				app = hs.application.find(name)
				if app then
					windows = app:allWindows()
					screenTarget = hs.screen.primaryScreen()
					if appGroup.withMultipleMonitors == 'tertiary' then
						screenTarget = hs.screen.find(obj.tertiaryMonitorName)
					elseif appGroup.withMultipleMonitors == 'secondary' then
						screenTarget = hs.screen.find(obj.secondaryMonitorName)
					end
					for k3, window in ipairs(windows) do
						window:moveToScreen(screenTarget)
						if appGroup.withMultipleMonitors == 'secondary' or appGroup.withMultipleMonitors == 'tertiary' then
							local appDimensions = appGroup.large
							if appGroup.withMultipleMonitors == 'tertiary' then
								appDimensions = appGroup.small
							end
							obj:gridset(appDimensions.x1, appDimensions.y1, appDimensions.w1, appDimensions.h1, appDimensions.nickname, app)
						end
					end
				end
			end
		end
	end
end

function obj:setSecondaryMonitor(secondaryName)
  obj.secondaryMonitorName = secondaryName
end

function obj:setTertiaryMonitor(tertiaryName)
  obj.tertiaryMonitorName = tertiaryName
end

function obj:setWatchedApps(apps)
  obj.watchedApps = apps
end

function obj:bindHotkeys(mapping)
  local def = {
		resetWindows										= function() obj:resetWindows() end,
    sizeLeftHalf                    = function() obj:gridset(0, 0, 50, 100) end,
    sizeRightHalf                   = function() obj:gridset(50, 0, 50, 100) end,
    sizeFull                        = function() obj:gridset(0, 0, 100, 100) end,
    sizeCentered                    = function() obj:gridset(12.5, 12.5, 75, 75) end,
    sizeLeft34ths                   = function() obj:gridset(0, 0, 73, 100, '34ths') end,
    size34thsCentered               = function() obj:gridset(12.5, 0, 75, 100) end,
    sizeRight14th                   = function() obj:gridset(73, 0, 27, 100, '14th') end,
    sizeRight14thTopHalfish         = function() obj:gridset(73, 0, 27, 55) end,
    sizeRight14thBottomHalfish      = function() obj:gridset(73, 60, 27, 40) end,
    sizeHalfHeightTopEdge           = function() obj:gridset('current', 0, 'current', 50) end,
    sizeHalfHeightBottomEdge        = function() obj:gridset('current', 50, 'current', 50) end,
    moveLeftEdge                    = function() obj:gridset(0, 'current', 'current', 'current') end,
    moveRightEdge                   = function() obj:gridset('opp', 'current', 'current', 'current') end
  }
  hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:init()

  hs.window.animationDuration = 0
  hs.window.setFrameCorrectness = true
  hs.grid.MARGINX = 0
  hs.grid.MARGINY = 0
  hs.grid.GRIDWIDTH = 100
  hs.grid.GRIDHEIGHT = 100

  self.computerName = hs.host.localizedName()
  self.screenClass = 'large' -- assumes large iMac
  if string.match(string.lower(self.computerName), 'macbook') then
    self.screenClass = 'small'
  end
  self.secondaryMonitorName = nil
	self.tertiaryMonitorName = nil
  self.watchedApps = {}
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
						if obj.screenClass == 'small' or (watchedApp.withMultipleMonitors == 'tertiary') then
							appDimensions = watchedApp.small
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
