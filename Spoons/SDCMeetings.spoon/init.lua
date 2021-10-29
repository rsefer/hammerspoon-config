--- === SDC Meetings ===
local obj = {}
obj.__index = obj
obj.name = "SDCMeetings"

function obj:updateFileFromCalendar()
	hs.execute('shortcuts run "Hammerspoon: Upcoming Meetings"')
end

function obj:getDataFromFile()
	output, status = hs.execute('cat ~/Documents/events.txt')
	output = output:gsub("\r?\n|\r", "")
	output = output:gsub("\n", "")
	if output == '' then return '[]' end
	return hs.json.decode(output)
end

function obj:createMenu()
	obj.menubar = hs.menubar.new():setIcon(iconsCalendar:setSize({ w = 16, h = 16 }))
end

function obj:updateMenu()
	menuItems = {}
	if obj:getDataFromFile() == nil then return end
	for i, ourEvent in ipairs(obj:getDataFromFile()) do
		titleString = ''
		if ourEvent.calendar == 'Sefer Design Co.' then
			titleString = titleString .. '🟩'
		else
			titleString = titleString .. '🟥'
		end
		titleString = titleString .. ' ' .. ourEvent.dateStart .. ' - '
		if ourEvent.urls ~= nil and tablelength(ourEvent.urls) > 0 then
			titleString = titleString .. '🎥'
		end
		titleString = titleString .. ourEvent.title
		table.insert(menuItems, {
			title = titleString,
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
				elseif workingURL ~= nil and string.find(workingURL, 'teams.microsoft.com') then
					hs.urlevent.openURL(workingURL)
				end
			end
		})
  end
	obj.menubar:setMenu(menuItems)
end

function obj:init()

	self.dataUpdateInterval = 60 * 15
	self.menuUpdateInterval = 60 * 5
	self.menubar = nil
	self.dataUpdateTimer = hs.timer.doEvery(obj.dataUpdateInterval, function()
		obj:updateFileFromCalendar()
	end):stop()
	self.menuUpdateTimer = hs.timer.doEvery(obj.menuUpdateInterval, function()
		obj:updateMenu()
	end):stop()

end

function obj:start()
	obj:updateFileFromCalendar()
	obj:createMenu()
	obj:updateMenu()
	obj.dataUpdateTimer:start()
end

function obj:stop()
	obj.menubar:delete()
	obj.dataUpdateTimer:stop()
	obj.menuUpdateTimer:stop()
end

return obj
