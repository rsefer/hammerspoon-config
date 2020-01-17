--- === SDC Timer ===
local obj = {}
obj.__index = obj
obj.name = "SDCTimer"
obj.timeIntervalSeconds = 15 * 60
obj.alertStyle = {
	atScreenEdge = 1
}

local iconBlack = hs.image.imageFromPath(hs.spoons.scriptPath() .. 'images/timer_black.pdf'):setSize({ w = hs.settings.get('menuIconSize'), h = hs.settings.get('menuIconSize') })
local iconGreen = hs.image.imageFromPath(hs.spoons.scriptPath() .. 'images/timer_green.pdf'):setSize({ w = hs.settings.get('menuIconSize'), h = hs.settings.get('menuIconSize') })

function timeString()
	local timeString = ''
	local remainingTime = obj.timeAccrued
	local timeAccruedHoursR = math.floor(obj.timeAccrued / 60 / 60)
	if (timeAccruedHoursR > 0) then
		timeString = timeAccruedHoursR .. ' hour'
		if timeAccruedHoursR ~= 1 then
			timeString = timeString .. 's'
		end
		remainingTime = remainingTime - (timeAccruedHoursR * 60 * 60)
	end
	local timeAccruedMinutesR = math.ceil(remainingTime / 60)
	if timeAccruedHoursR > 0 and timeAccruedMinutesR > 0 then
		timeString = timeString .. ', '
	end
	timeString = timeString .. timeAccruedMinutesR .. ' minute'
	if timeAccruedMinutesR ~= 1 then
		timeString = timeString .. 's'
	end
	return timeString
end

function clientNameFromID(ID)
	local name = nil
	for i, client in ipairs(obj.clients) do
		if client.uuid == ID then
			name = client.name
			break
		end
	end
	return name
end

function updateTimeElapsedAlert()
	local elapsedString = timeString()
	if obj.activeClient ~= nil then
		elapsedString = obj.activeClient.name .. ': ' .. elapsedString
	end
	hs.alert.show(elapsedString, obj.alertStyle, 9)
end

function updateTimeElapsed()
	obj.timeAccrued = os.time() - obj.timeStart
end

function obj:toggleTimer()
  if obj.timerMain and obj.timerMain:running() then
    obj:stop()
  else
		obj:timerReset()
		obj:showChooser()
  end
end

function obj:timerReset()
	obj.activeClient = nil
	obj.timeAccrued = 0
	obj.timeStart = nil
	obj.timerMain = hs.timer.doEvery(obj.timeIntervalSeconds, function()
		updateTimeElapsedAlert()
	end):stop()
	obj.timerCounter = hs.timer.doEvery(60, function()
		updateTimeElapsed()
	end):stop()
end

function obj:showChooser()
	obj.clientChooser:show()
end

function obj:getClients()
	status, body, headers = hs.http.get(hs.settings.get('biz_api_client_endpoint') .. '?access_token=' .. hs.settings.get('biz_api_key') .. '&sortBy=recentActivityDate')
	if status == 200 then
		clientsRaw = hs.json.decode(body)
		clients = {
			{
				uuid = 0,
				text = '---',
				name = '---'
			}
		}
		for i, client in ipairs(clientsRaw) do
			table.insert(clients, {
				uuid = client.id,
				text = client.name,
				name = client.name,
				subText = client.contact
			})
		end
		self.clients = clients
		return clients
	else
		return {}
	end
end

function obj:logTime(timeMinutes)
	if timeMinutes == nil then
		obj.isManualLog = true
		obj:showChooser()
		return true
	end
	name = obj.activeClient.name:gsub('%W', '')
	lengthlimit = 15
	if string.len(name) > lengthlimit then
		name = string.sub(name, 1, lengthlimit)
	end
	local ltstring = 'lt add ' .. obj.activeClient.uuid .. ' ' .. name .. ' ' .. timeMinutes
	hs.execute(ltstring, true)
end

function obj:bindHotkeys(mapping)
  local def = {
		toggleTimer = hs.fnutils.partial(self.toggleTimer, self),
		logTime = hs.fnutils.partial(self.logTime, self)
  }
  hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:init()

	setupSetting('biz_api_client_endpoint')
	setupSetting('biz_api_key')

	self.logger = hs.logger.new(self.name, 'info')
	self.timerMenu = hs.menubar.new()
		:setClickCallback(obj.toggleTimer)
		:setIcon(iconBlack, true)
	self.timerMain = nil
	self.timerCounter = nil
	self.isManualLog = false

	self:timerReset()

	hs.timer.doAfter(1, function()
		obj.clientChooser = hs.chooser.new(function(choice)
			if choice then
				if choice.uuid ~= 0 then
					obj.activeClient = choice
				end
				if obj.isManualLog == true then
					button, timeMinutes = hs.dialog.textPrompt('Log Minutes:', 'For ' .. obj.activeClient.name, '15', 'Log', 'Cancel')
					obj.isManualLog = false
					if button ~= 'Log' or timeMinutes == nil then
						return
					end
					obj:logTime(timeMinutes)
				else
					obj:start()
				end
			end
			obj.clientChooser:query(nil)
		end)
			:width(30)
			:rows(6)
			:searchSubText(true)
			:attachedToolbar(hs.webview.toolbar.new('clientChooserToolbar', {{
				id = 'clientRefresh',
				label = 'Refresh',
				selectable = true,
				fn = function() obj.clientChooser:choices(obj:getClients()) end
			}}
			):sizeMode('small'):displayMode('label'))
			:choices(self:getClients())
	end)

end

function obj:start()
	local time = os.date('*t')
	obj.timeStart = os.time()
	obj.timerMain:start()
	obj.timerCounter:start()
	obj.timerMenu:setIcon(iconGreen, false)
	local timeStringStart = 'Timer started at ' .. os.date('%I:%M%p')
	if obj.activeClient ~= nil then
		timeStringStart = obj.activeClient.name .. ': ' .. timeStringStart
	end
	hs.alert.show(timeStringStart, obj.alertStyle, 3)
	obj.logger:i(timeStringStart)
end

function obj:stop()
	obj.timerMain:stop()
	obj.timerCounter:stop()
	obj.timerMenu:setIcon(iconBlack, true)
	local timeStringEnd = 'Timer stopped. Total time: ' .. timeString()
	if obj.activeClient ~= nil then
		timeStringEnd = obj.activeClient.name .. ': ' .. timeStringEnd
		obj:logTime(math.ceil(obj.timeAccrued / 60))
	end
	hs.alert.show(timeStringEnd, obj.alertStyle, 7)
	obj.logger:i(timeStringEnd)
	obj:timerReset()
end

return obj
