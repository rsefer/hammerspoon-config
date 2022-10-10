--- === SDC Meetings ===
local obj = {}
obj.__index = obj
obj.name = "SDCMeetings"

function obj:updateFileFromCalendar()
	hs.shortcuts.run(obj.shortcutName)
end

function obj:getDataFromFile()
	file = io.open(obj.eventsFilePath, "rb")
	output = file:read('*a')
	file:close()
	output = output:gsub("\r?\n|\r", "")
	output = output:gsub("\n", "")
	if output == '' then output = '[]' end
	return hs.json.decode(output)
end

function obj:createMenu()
	obj.menubar = hs.menubar.new():setIcon(iconCalendar:setSize({ w = 16, h = 16 }))
end

function obj:updateMenu()
	menuItems = {}
	data = obj:getDataFromFile()
	if data ~= nil and #data > 0 then
		has2DigitHours = false
		for i, ourEvent in ipairs(data) do
			parsedEndDate = parse_json_date(ourEvent.dateEnd)
			if parsedEndDate > os.time() then
				workingImage = iconHouse
				if ourEvent.calendar == 'Sefer Design Co.' then
					workingImage = iconBriefcase
				end
				workingDate = os.date('%I:%M%p', parse_json_date(ourEvent.dateStart))
				if workingDate:sub(1, 1) == '0' then
					workingDate = workingDate:sub(2, string.len(workingDate))
					if has2DigitHours then
						workingDate = ' ' .. workingDate
					end
				else
					has2DigitHours = true
				end
				titleString = hs.styledtext.new(workingDate, { font = { name = 'SF Mono' } }) .. ' - ' .. ourEvent.title
				if ourEvent.urls ~= nil and #ourEvent.urls > 0 then
					titleString = titleString .. ' ' .. hs.styledtext.new(utf8.char(0x10034A), { font = { name = 'SF Pro' } }) -- character is video icon. /common/icons.lua
				end
				table.insert(menuItems, {
					title = titleString,
					image = workingImage:setSize({ w = 16, h = 16 }),
					tooltip = ourEvent.notes,
					fn = function()
						workingURL = nil
						if ourEvent.urls ~= nil and #ourEvent.urls > 0 then
							workingURL = ourEvent.urls[1]:gsub("%s+", "")
						end
						if workingURL ~= nil and string.find(workingURL, 'google.com') then
							hs.urlevent.openURL('https://accounts.google.com/AccountChooser/signinchooser?continue=' .. workingURL .. '&hl=en&flowName=GlifWebSignIn&flowEntry=AccountChooser')
							-- hs.execute('open -na \'Google Chrome\' --args --profile-directory="Profile 1" "' .. workingURL .. '"',) -- this doesn't work as expected from HS
						elseif workingURL ~= nil and string.find(workingURL, 'zoom.us') then
							urlParts = hs.http.urlParts(workingURL)
							workingFinalURL = 'zoommtg://zoom.us/join?confno=' .. urlParts.lastPathComponent
							if urlParts.query ~= nil then
								workingFinalURL = workingFinalURL .. '&' .. urlParts.query
							end
							hs.urlevent.openURL(workingFinalURL)
						elseif workingURL ~= nil and (string.find(workingURL, 'teams.microsoft.com') or string.find(workingURL, 'facetime.apple.com')) then
							hs.urlevent.openURL(workingURL)
						end
					end
				})
			end
		end
	end
	if #menuItems == 0 then
		table.insert(menuItems, {
			title = 'No upcoming events.'
		})
	end
	obj.menubar:setMenu(menuItems)
end

function obj:init()

	self.shortcutName = 'Hammerspoon: Upcoming Meetings'
	self.eventsFilePath = '/Users/rsefer/Documents/events.txt'
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
