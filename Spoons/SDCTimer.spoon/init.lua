--- === SDC Timer ===
local obj = {}
obj.__index = obj
obj.name = "SDCTimer"
obj.timeIntervalSeconds = 15 * 60

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
	notificationSubTitle = nil
	if obj.activeClient ~= nil then
		notificationSubTitle = obj.activeClient.name
	end
	hs.notify.new({
		title = 'Tracking Time',
		subTitle = notificationSubTitle,
		informativeText = minutesToClock(obj.timeAccrued / 60, false, true),
		withdrawAfter = 5,
		setIdImage = hs.image.imageFromName(hs.image.systemImageNames.StatusAvailable)
	}):send()
end

function updateTimeElapsed()
	obj.timeAccrued = os.time() - obj.timeStart
	obj.timerMenu:setTitle(hs.styledtext.new(' ' .. minutesToClock(obj.timeAccrued / 60, false, false), { textFont = 'SF Mono' }))
end

function obj:toggleTimer()
  if obj.timerMain and obj.timerMain:running() then
    obj:stop()
  else
		obj:timerReset()
		if obj.clientChooser:isVisible() then
			obj.clientChooser:hide()
		else
			obj.clientChooser:show()
		end
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
		hs.settings.set('clients', clients)
		return clients
	else
		return hs.settings.get('clients')
	end
end

function obj:logTime(timeMinutes)
	if not timeMinutes then
		obj.isManualLog = true
		obj.clientChooser:show()
		return true
	end
	name = obj.activeClient.name:gsub('%W', '')
	lengthlimit = 15
	if string.len(name) > lengthlimit then
		name = string.sub(name, 1, lengthlimit)
	end
	local ltstring = 'lt add ' .. obj.activeClient.uuid .. ' ' .. name .. ' ' .. timeMinutes
	output, status = hs.execute(ltstring, true)
	if status then
		output, status = hs.execute('lt ct ' .. obj.activeClient.uuid, true)
		clientTotalMinutes = output:gsub("[\n\r]", "")

		notificationSubTitle = nil
		if obj.activeClient ~= nil then
			notificationSubTitle = obj.activeClient.name
		end
		hs.notify.new({
			title = 'Total Client Time',
			subTitle = notificationSubTitle,
			informativeText = minutesToClock(clientTotalMinutes, false, true),
			withdrawAfter = 15,
			setIdImage = hs.image.imageFromName(hs.image.systemImageNames.StatusAvailable)
		}):send()
	end

end

function obj:bindHotkeys(mapping)
  hs.spoons.bindHotkeysToSpec({
		toggleTimer = hs.fnutils.partial(self.toggleTimer, self),
		logTime = hs.fnutils.partial(self.logTime, self)
  }, mapping)
end

function obj:init()

	setupSetting('biz_api_client_endpoint')
	setupSetting('biz_api_key')

	self.logger = hs.logger.new(self.name, 'info')
	self.timerMenu = hs.menubar.new()
		:setClickCallback(obj.toggleTimer)
		:setIcon(iconTimerOff, true)
	self.timerMain = nil
	self.timerCounter = nil
	self.clientChooser = hs.chooser.new(function(choice)
		if choice then
			if choice.uuid ~= 0 then
				obj.activeClient = choice
			end
			if obj.isManualLog == true then
				hs.application.get('Hammerspoon'):activate()
				button, timeMinutes = hs.dialog.textPrompt('Log Minutes:', 'For ' .. obj.activeClient.name, '15', 'Log', 'Cancel')
				obj.isManualLog = false
				if button ~= 'Log' or not timeMinutes then
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
		:attachedToolbar(hs.webview.toolbar.new('clientChooserToolbar', {
			{
				id = 'clientRefresh',
				label = 'Refresh',
				selectable = true,
				fn = function() obj.clientChooser:choices(obj:getClients()) end
			},
			{
				id = 'staticLog',
				label = 'Log',
				selectable = true,
				fn = function()
					if obj.clientChooser:isVisible() then
						obj.clientChooser:hide()
					end
					obj:logTime()
				end
			}
		}
		):sizeMode('small'):displayMode('label'))
		:choices(self:getClients())
	self.isManualLog = false
	self.clients = self:getClients()

	hs.urlevent.bind('toggleTimer', function(event, params)
		self:toggleTimer()
	end)

	self:timerReset()

end

function obj:start()
	local time = os.date('*t')
	obj.timeStart = os.time()
	obj.timerMain:start()
	obj.timerCounter:start()
	obj.timerMenu:setIcon(iconTimerOn, false)
	local timeStringStart = 'Timer started at ' .. os.date('%I:%M%p')
	if obj.activeClient ~= nil then
		timeStringStart = obj.activeClient.name .. ': ' .. timeStringStart
	end

	notificationSubTitle = nil
	if obj.activeClient ~= nil then
		notificationSubTitle = obj.activeClient.name
	end
	hs.notify.new({
		title = 'Starting Timer',
		subTitle = notificationSubTitle,
		withdrawAfter = 3,
		setIdImage = hs.image.imageFromName(hs.image.systemImageNames.StatusAvailable)
	}):send()

	updateTimeElapsed()
	obj.logger:i(timeStringStart)
end

function obj:stop()
	obj.timerMain:stop()
	obj.timerCounter:stop()
	obj.timerMenu:setIcon(iconTimerOff, true)
		:setTitle()

	minutesTimed = math.ceil(obj.timeAccrued / 60)
	local timeStringEnd = 'Timer stopped. Logged time: ' .. minutesToClock(minutesTimed, false, true)
	if obj.activeClient ~= nil then
		timeStringEnd = obj.activeClient.name .. ': ' .. timeStringEnd
		obj:logTime(minutesTimed)
	end

	notificationSubTitle = nil
	if obj.activeClient ~= nil then
		notificationSubTitle = obj.activeClient.name
	end
	hs.notify.new({
		title = 'Logged Time',
		subTitle = notificationSubTitle,
		informativeText = minutesToClock(minutesTimed, false, true),
		withdrawAfter = 15,
		setIdImage = hs.image.imageFromName(hs.image.systemImageNames.StatusAvailable)
	}):send()

	obj.logger:i(timeStringEnd)
	obj:timerReset()
end

return obj
