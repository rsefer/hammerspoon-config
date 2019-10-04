--- === SDC HomeAssistant ===
local obj = {}
obj.__index = obj
obj.name = "SDCHomeAssistant"

function obj:switchLights(on)

	local groupLightsName = 'group.all_lights'

	status, data, headers = hs.http.asyncGet(obj.api_endpoint .. 'states/' .. groupLightsName, {
		['Authorization'] = 'Bearer ' .. obj.api_key,
		['Content-Type'] = 'application/json'
	}, function(cstatus, cbody, cheaders)
		local json = hs.json.decode(cbody)
		if json.state then
			local action = 'on'
			if json.state == 'on' then
				action = 'off'
			end
			status, data, headers = hs.http.asyncPost(obj.api_endpoint .. 'services/light/turn_' .. action, '{"entity_id":"' .. groupLightsName .. '"}', {
				['Authorization'] = 'Bearer ' .. obj.api_key,
				['Content-Type'] = 'application/json'
			}, function(cstatus, cbody, cheaders)
				--
			end)
		end
	end)

  return self

end

function obj:toggleSecondaryMonitor(action)
	local secondaryMonitorEntityID = 'switch.secondary_monitor'
	if action == nil then
		action = 'on'
	end
	status, data, headers = hs.http.asyncPost(obj.api_endpoint .. 'services/switch/turn_' .. action, '{"entity_id":"' .. secondaryMonitorEntityID .. '"}', {
		['Authorization'] = 'Bearer ' .. obj.api_key,
		['Content-Type'] = 'application/json'
	}, function(cstatus, cbody, cheaders)
		--
		if action == 'on' then
			obj:moveWindows()
		end
	end)
end

function obj:moveWindows()
	for k, watchedApp in ipairs(obj.watchedApps) do
		app = hs.application.find(watchedApp.name)
		if app ~= nil then
			windows = app:allWindows()
			screen = hs.screen.find(watchedApp.monitor)
			delay = 6
			for k2, window in ipairs(windows) do
				hs.timer.doAfter(delay, function()
					window:moveToScreen(screen)
					if watchedApp.large ~= nil then
						hs.timer.doAfter(1, function()
							spoon.SDCWindows:gridset(watchedApp.large.x1, watchedApp.large.y1, watchedApp.large.w1, watchedApp.large.h1, watchedApp.large.nickname, app)
						end)
					end
				end)
			end
		end
	end
end

function obj:bindHotkeys(mapping)
  local def = {
		switchLights = hs.fnutils.partial(self.switchLights, self),
		turnOnSecondaryMonitor = hs.fnutils.partial(self.toggleSecondaryMonitor, self)
  }
  hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:start()

	self.stateWatcher = hs.caffeinate.watcher.new(function(state)
		if state == hs.caffeinate.watcher.systemDidWake or state == hs.caffeinate.watcher.systemWillSleep then
			action = 'off'
			if state == hs.caffeinate.watcher.systemDidWake then
				action = 'on'
			end
			self:toggleSecondaryMonitor(action)
		end

	end)
	self.stateWatcher:start()

end

return obj
