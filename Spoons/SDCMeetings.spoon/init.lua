--- === SDC Meetings ===
local obj = {}
obj.__index = obj
obj.name = "SDCMeetings"

function obj:updateFileFromCalendar()
	hs.execute('shortcuts run "' .. obj.shortcutName .. '"')
end

function obj:getDataFromFile()
	output, status = hs.execute('cat ' .. obj.eventsFilePath)
	output = output:gsub("\r?\n|\r", "")
	output = output:gsub("\n", "")
	if output == '' then return '[]' end
	return hs.json.decode(output)
end

function obj:createMenu()
	obj.menubar = hs.menubar.new():setIcon(iconCalendar:setSize({ w = 16, h = 16 }))
end

function obj:updateMenu()
	menuItems = {}
	data = obj:getDataFromFile()
	if data ~= nil and tablelength(data) > 0 then
		for i, ourEvent in ipairs(data) do
			parsedEndDate = parse_json_date(ourEvent.dateEnd)
			if parsedEndDate > os.time() then
				workingStateImage = iconHouse
				if ourEvent.calendar == 'Sefer Design Co.' then
					workingStateImage = iconBriefcase
				end
				workingModImage = nil
				if ourEvent.urls ~= nil and tablelength(ourEvent.urls) > 0 then
					workingModImage = iconVideoWhite:setSize({ w = 24, h = 24 })
				end
				workingDate = os.date('%I:%M%p', parse_json_date(ourEvent.dateStart))
				if workingDate:sub(1, 1) == '0' then
					workingDate = workingDate:sub(2, string.len(workingDate))
				end
				titleString = workingDate .. ' - '
				titleString = titleString .. ourEvent.title
				table.insert(menuItems, {
					title = hs.styledtext.new(titleString, { font = { name = 'SF Mono', size = 12 } }),
					state = 'on',
					onStateImage = workingStateImage:setSize({ w = 36, h = 36 }),
					image = workingModImage,
					fn = function()
						workingURL = nil
						if ourEvent.urls ~= nil and tablelength(ourEvent.urls) > 0 then
							workingURL = ourEvent.urls[1]
						end
						if workingURL ~= nil and string.find(workingURL, 'google.com') then
							hs.urlevent.openURL('https://accounts.google.com/AccountChooser/signinchooser?continue=' .. workingURL .. '&hl=en&flowName=GlifWebSignIn&flowEntry=AccountChooser')
							-- hs.execute('open -na \'Google Chrome\' --args --profile-directory="Profile 1" "' .. workingURL .. '"',) -- this doesn't work as expected from HS
						elseif workingURL ~= nil and string.find(workingURL, 'zoom.us') then
							urlParts = hs.http.urlParts(workingURL)
							hs.urlevent.openURL('zoommtg://zoom.us/join?confno=' .. urlParts.lastPathComponent .. '&' .. urlParts.query)
						elseif workingURL ~= nil and (string.find(workingURL, 'teams.microsoft.com') or string.find(workingURL, 'facetime.apple.com')) then
							hs.urlevent.openURL(workingURL)
						end
					end
				})
			end
		end
	end
	if tablelength(menuItems) == 0 then
		table.insert(menuItems, {
			title = 'No upcoming events.'
		})
	end
	obj.menubar:setMenu(menuItems)
end

function obj:init()

	self.shortcutName = 'Hammerspoon: Upcoming Meetings'
	self.eventsFilePath = '~/Documents/events.txt'
	self.dataUpdateInterval = 60 * 30
	self.menuUpdateInterval = 60 * 10
	self.menubar = nil
	self.dataUpdateTimer = hs.timer.doEvery(obj.dataUpdateInterval, function()
		obj:updateFileFromCalendar()
	end):stop()
	self.menuUpdateTimer = hs.timer.doEvery(obj.menuUpdateInterval, function()
		obj:updateMenu()
	end):stop()
	self.dataPathwatcher = hs.pathwatcher.new(self.eventsFilePath, function()
		obj:updateMenu()
	end):stop()

end

function obj:start()
	obj:createMenu()
	obj.dataUpdateTimer:start()
	obj.dataPathwatcher:start()
	obj:updateFileFromCalendar()
end

function obj:stop()
	obj.dataPathwatcher:stop()
	obj.menubar:delete()
	obj.dataUpdateTimer:stop()
	obj.menuUpdateTimer:stop()
end

return obj
