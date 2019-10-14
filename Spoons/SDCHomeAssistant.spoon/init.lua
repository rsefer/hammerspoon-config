--- === SDC HomeAssistant ===
local obj = {}
obj.__index = obj
obj.name = "SDCHomeAssistant"

local viewWidth = 600
local viewHeight = 500
local iconSize = 14.0
local iconFull = hs.image.imageFromPath(hs.spoons.scriptPath() .. 'images/home-assistant.pdf')
local icon = iconFull:setSize({ w = iconSize, h = iconSize })

function obj:toggleWebview()
  if obj.isShown then
    obj.haWebview:hide()
    obj.isShown = false
  else
    obj.haWebview:show():bringToFront(true)
		obj.haWebview:hswindow():moveToScreen(hs.screen.primaryScreen()):focus()
    obj.isShown = true
  end
end

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
			hs.layout.apply(spoon.SDCWindows.windowLayout)
		end
	end)
end

function obj:bindHotkeys(mapping)
  local def = {
		switchLights = hs.fnutils.partial(self.switchLights, self),
		turnOnSecondaryMonitor = hs.fnutils.partial(self.toggleSecondaryMonitor, self)
  }
  hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:init()

	self.isShown = false
	self.haMenu = hs.menubar.new()
    :setClickCallback(obj.toggleWebview)
    :setIcon(icon, true)

  self.haMenuFrame = self.haMenu:frame()

	self.haWebview = hs.webview.newBrowser(hs.geometry.rect((self.haMenuFrame.x + self.haMenuFrame.w / 2) - (viewWidth / 2), self.haMenuFrame.y, viewWidth, viewHeight), { developerExtrasEnabled = true })
    :allowTextEntry(true)
		:shadow(true)
		:windowCallback(function(action, webview, state)
			if action == 'focusChange' and state ~= true then
				self.haWebview:hide()
				self.isShown = false
			end
		end)

end

function obj:start()

	self.haWebview:url(obj.api_domain)

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
