--- === SDC HomeAssistant ===
local obj = {}
obj.__index = obj
obj.name = "SDCHomeAssistant"

function obj:switchLights(on)

	-- newLight = 'on'
	-- if obj.lastLight == 'on' then
	-- 	newLight = 'off'
	-- 	obj.lastLight = 'off'
	-- end

	-- postString = obj.api_endpoint .. 'services/light/turn_' .. newLight
	postString = obj.api_endpoint .. 'services/light/toggle'

	status, data, headers = hs.http.asyncPost(postString, '{"entity_id":"group.all_lights"}', {
		['Authorization'] = 'Bearer ' .. obj.api_key,
		['Content-Type'] = 'application/json'
	}, function(cstatus, cbody, cheaders)
		-- print(cstatus)
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

function obj:init()
	obj.lastLight = 'off'
end

return obj
