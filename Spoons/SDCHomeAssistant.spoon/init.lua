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
				-- print(cstatus)
			end)
		end
	end)

  return self

end

function obj:setConfig(api_endpoint, api_key)
	obj.api_endpoint = api_endpoint
  obj.api_key = api_key
end

function obj:bindHotkeys(mapping)
  local def = {
    switchLights = hs.fnutils.partial(self.switchLights, self)
  }
  hs.spoons.bindHotkeysToSpec(def, mapping)
end

return obj
