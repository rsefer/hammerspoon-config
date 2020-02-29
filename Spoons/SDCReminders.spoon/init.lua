--- === SDC Reminders ===
local obj = {}
obj.__index = obj
obj.name = "SDCReminders"

local viewWidth = 800
local viewHeight = 450

function obj:getListNames()
	-- if permissions won't enable, run the following:
	-- hs.execute('osascript -e \'tell application "Reminders" to return default account\'')
	asBool, asObject, asDesc = hs.osascript.applescript([[
		tell application "Reminders"
			set myLists to lists of default account
			set listNames to {}
			repeat with theList in myLists
				copy name of theList to the end of the |listNames|
			end repeat
			listNames
		end tell
	]])
	return asObject
end

function obj:setHTML()
	local indexHTML = ''
	local optionsString = ''
	listNames = obj:getListNames()
	if not listNames then return end
	for i, listName in ipairs(listNames) do
		optionsString = optionsString .. '<option'
		if i == 1 then
			optionsString = optionsString .. ' selected'
		end
		optionsString = optionsString .. '>' .. listName .. '</option>'
	end
	for line in io.lines(hs.spoons.scriptPath() .. "index.html") do
		workingLine = line
		if string.match(line, '{{ lists }}') then
			workingLine = optionsString
		end
		indexHTML = indexHTML .. workingLine .. "\n"
	end
	obj.remindersWebview:html(indexHTML)
end

function obj:toggleWebview()
  if obj.isShown then
    obj.remindersWebview:hide()
    obj.isShown = false
  else
		obj.remindersWebview:reload()
		obj:setHTML()
    obj.remindersWebview:show():bringToFront(true)
		obj.remindersWebview:hswindow():moveToScreen(hs.screen.primaryScreen()):focus()
    obj.isShown = true
  end
end

function obj:bindHotkeys(mapping)
  local def = {
    toggleWebview = hs.fnutils.partial(self.toggleWebview, self)
  }
  hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:init()

  self.isShown = false
	local frame = hs.screen.primaryScreen():frame()
  self.rect = hs.geometry.rect((frame.w / 2) - (viewWidth / 2), (frame.h / 2) - (viewHeight / 2), viewWidth, viewHeight)
  self.remindersJS = hs.webview.usercontent.new('idhsremindersWebview'):setCallback(function(message)
		if message.body.reminder ~= nil then
			local reminder = message.body.reminder
			reminderScpt = [[
				tell application "Reminders"
					set currentDate to my convertDate("]] .. reminder.date .. ' ' .. reminder.time .. [[")
					set mylist to list "]] .. reminder.list .. [["
					tell mylist
						make new reminder at end with properties {name: "]] .. reminder.name .. [[", due date:currentDate, remind me date:currentDate}
					end tell
				end tell

				to convertDate(textDate)
					-- YYYY-MM-DD HH:MM(am/pm)
					set resultDate to the current date

					set the year of resultDate to (text 1 thru 4 of textDate)
					set the month of resultDate to (text 6 thru 7 of textDate)
					set the day of resultDate to (text 9 thru 10 of textDate)
					set the time of resultDate to 0

					set the hours of resultDate to (text 12 thru 13 of textDate)
					set the minutes of resultDate to (text 15 thru 16 of textDate)

					return resultDate
				end convertDate
			]]
			-- Fantastical -- tell application "Fantastical" to parse sentence "Remind ']] .. reminder.name .. [[' at ]] .. reminder.time .. [[ on ]] .. reminder.date .. [[ /]] .. reminder.list .. [[" with add immediately
			asBool, asObject, asDesc = hs.osascript.applescript(reminderScpt)
			if asBool then
				obj:toggleWebview()
				hs.notify.new(function()
					hs.application.launchOrFocus('Reminders')
				end, {
					hasActionButton = true,
					actionButtonTitle = 'Open',
					title = 'Reminder added:',
					subTitle = reminder.name,
					informativeText = 'For: ' .. reminder.date .. ' @ ' .. reminder.time
				}):setIdImage(hs.image.imageFromAppBundle(hs.application.find('Reminders'):bundleID())):send()
			end
		end
  end)
  self.remindersWebview = hs.webview.newBrowser(self.rect, { developerExtrasEnabled = true }, self.remindersJS)
    :allowTextEntry(true)
    :shadow(true)
		:windowCallback(function(action, webview, state)
			if action == 'focusChange' and state ~= true then
				self.remindersWebview:hide()
		    self.isShown = false
			end
		end)
	self:setHTML()

end

return obj
