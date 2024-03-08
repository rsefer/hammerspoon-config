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
	shouldShow = true
	for i, device in ipairs(hs.audiodevice.allInputDevices()) do
		if device:inUse() then -- don't show updates if microphone is being used
			shouldShow = false
			break
		end
	end
	if not shouldShow then return end
	updateTimeElapsed()
	-- notificationSubTitle = nil
	-- if obj.activeClient ~= nil then
	-- 	notificationSubTitle = obj.activeClient.name
	-- end
	-- hs.notify.new({
	-- 	title = 'Tracking Time',
	-- 	subTitle = notificationSubTitle,
	-- 	informativeText = minutesToClock(math.ceil(obj.timeAccrued / 60), false, true),
	-- 	withdrawAfter = 5,
	-- 	setIdImage = iconTimerOnAlt,
	-- 	contentImage = iconTimerOnAlt
	-- }):send()
	updateTimeElapsedRectangle()
end

function updateTimeElapsedRectangle()
	textRaw = minutesToClock(math.ceil(obj.timeAccrued / 60), false, true)
	textTime = os.date('%I:%M%p')

	timeElapsedRectangles = {}
	rectangleTimers = {}
	for i, screen in ipairs(hs.screen.allScreens()) do
		screenFrame = screen:fullFrame()
		alpha = 0.5
		strokeWidth = -1.5
		if screen:name() == hs.settings.get('secondaryMonitorName') then
			alpha = 0.7
		end
		textElapsed = hs.styledtext.new(textRaw, {
			font = {
				name = 'SF Mono Semibold',
				size = screenFrame.h / 15
			},
			color = { ['hex'] = '#ffffff' },
			strokeColor = { ['hex'] = '#000000' },
			strokeWidth = strokeWidth
		})
		textElapsedFrame = hs.drawing.getTextDrawingSize(textElapsed)
		textClock = hs.styledtext.new(textTime, {
			font = {
				name = 'SF Mono',
				size = screenFrame.h / 30
			},
			color = { ['hex'] = '#ffffff' },
			strokeColor = { ['hex'] = '#000000' },
			strokeWidth = strokeWidth
		})
		textClockFrame = hs.drawing.getTextDrawingSize(textClock)
		elements = {
			{
				type = 'rectangle',
				action = 'fill',
				frame = {
					x = '0%',
					y = '0%',
					h = '100%',
					w = '100%'
				},
				fillColor = { ['hex'] = '#1db954', ['alpha'] = alpha }
			},
			{
				type = 'text',
				text = textElapsed,
				frame = {
					x = (screenFrame.w / 2) - (textElapsedFrame.w / 2),
					y = (screenFrame.h / 2) - (textElapsedFrame.h * 0.75),
					h = textElapsedFrame.h,
					w = textElapsedFrame.w
				}
			},
			{
				type = 'text',
				text = textClock,
				frame = {
					x = (screenFrame.w / 2) - (textClockFrame.w / 2),
					y = (screenFrame.h / 2) + (textElapsedFrame.h * 0.25),
					h = textClockFrame.h,
					w = textClockFrame.w
				}
			}
		}
		if obj.activeClient then
			textClient = hs.styledtext.new(obj.activeClient.name, {
				font = {
					name = 'SF Mono Semibold',
					size = screenFrame.h / 30
				},
				color = { ['hex'] = '#ffffff' },
				strokeColor = { ['hex'] = '#000000' },
				strokeWidth = strokeWidth
			})
			textClientFrame = hs.drawing.getTextDrawingSize(textClient)
			table.insert(elements, {
				type = 'text',
				text = textClient,
				frame = {
					x = (screenFrame.w / 2) - (textClientFrame.w / 2),
					y = '5%',
					h = textClientFrame.h,
					w = textClientFrame.w
				}
			})
		end
		timeElapsedRectangles[i] = hs.canvas.new({ x = 0, y = 0, h = screenFrame.h, w = screenFrame.w })
			:frame(screenFrame)
			:appendElements(elements)
			:show(0.5)
		rectangleTimers[i] = hs.timer.doAfter(3, function()
			timeElapsedRectangles[i]:delete(0.5)
		end)
	end

end

function updateTimeElapsed()
	obj.timeAccrued = os.time() - obj.timeStart
	obj.timerMenu:setTitle(hs.styledtext.new(' ' .. obj.activeClient.nameAbbreviation .. ' ' .. minutesToClock(obj.timeAccrued / 60, false, false), { textFont = 'SF Mono' }))
end

function ltScriptFullPath()
	-- this can fail after OS updates some times due to changes
	-- run `sudo xcodebuild -license && xcodebuild -runFirstLaunch` to solve this
	return 'python3 /Users/rsefer/dotfiles/bin/lt'
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
				name = '---',
				nameAbbreviation = '- - -'
			}
		}
		for i, client in ipairs(clientsRaw) do
			clientData = {
				uuid = client.id,
				text = client.name,
				name = client.name,
				subText = client.contact
			}
			local firstLetters = {}
			for word in string.gmatch(clientData.name, "%w+") do
				table.insert(firstLetters, word:sub(1,1))
			end
			clientData.nameAbbreviation = table.concat(firstLetters)
			table.insert(clients, clientData)
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
	local ltstring = ltScriptFullPath() .. ' add ' .. obj.activeClient.uuid .. ' ' .. name .. ' ' .. timeMinutes
	status, output = hs.osascript.applescript('do shell script "' .. ltstring .. '"')
	if status then
		local ltstring2 = ltScriptFullPath() .. ' ct ' .. obj.activeClient.uuid
		status2, output2 = hs.osascript.applescript('do shell script "' .. ltstring2 .. '"')
		clientTotalMinutes = output2:gsub("[\n\r]", "")
		notificationSubTitle = nil
		if obj.activeClient ~= nil then
			notificationSubTitle = obj.activeClient.name
		end
		hs.notify.new({
			title = 'Total Client Time',
			subTitle = notificationSubTitle,
			informativeText = minutesToClock(clientTotalMinutes, false, true),
			withdrawAfter = 15,
			setIdImage = iconTimerAlt,
			contentImage = iconTimerAlt
		}):send()
	else
		hs.notify.new({
			title = 'FAILED TO LOG',
			subTitle = ltstring,
			withdrawAfter = 999,
			setIdImage = iconTimerFail,
			contentImage = iconTimerFail
		}):send()
		obj.logger:i('FAILED TO LOG: ' .. ltstring)
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
	self.timerMenu = hs.menubar.new():autosaveName('Timer')
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
		:rows(7)
		:searchSubText(true)
		:attachedToolbar(hs.webview.toolbar.new('clientChooserToolbar', {
			{
				id = 'clientRefresh',
				label = 'Refresh',
				image = iconRefresh,
				selectable = true,
				fn = function() obj.clientChooser:choices(obj:getClients()) end
			},
			{
				id = 'staticLog',
				label = 'Log',
				image = iconNote,
				selectable = true,
				fn = function()
					if obj.clientChooser:isVisible() then
						obj.clientChooser:hide()
					end
					obj:logTime()
				end
			}
		}
		):sizeMode('small'):displayMode('both'))
		:choices(self:getClients())
	self.isManualLog = false
	self.clients = self:getClients()
	self.timeElapsedRectangle = nil

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
		setIdImage = iconTimerOn,
		contentImage = iconTimerOn
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
		setIdImage = iconTimerSuccess,
		contentImage = iconTimerSuccess
	}):send()

	obj.logger:i(timeStringEnd)
	obj:timerReset()
end

return obj
