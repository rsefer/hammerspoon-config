--- === SDC Phone ===
local obj = {}
obj.__index = obj
obj.name = "SDCPhone"

local function callPhone(phone, protocol)
	return function()
		workingProtocol = 'tel'
		workingParam = '?audio=yes'
		if protocol ~= nil then
			workingProtocol = protocol
			if protocol == 'facetime' then
				workingParam = ''
			end
		end
		hs.osascript.applescript([[
			do shell script "open ]] .. protocol .. [[://" & quoted form of "]] .. phone .. workingParam .. [["
			tell application "System Events"
				repeat while not (button "Call" of window 1 of application process "FaceTime" exists)
					delay 1
				end repeat
				click button "Call" of window 1 of application process "FaceTime"
			end tell
		]])
		-- hs.osascript.applescript('open location "tel://' .. phone .. '?audio=yes"')
		-- hs.urlevent.openURL('tel://' .. phone ..'?audio=yes')
  end
end

local function textPhone(phone, text, protocol)
	return function()
		button, message = hs.dialog.textPrompt('Message to ' .. text, '')
		if message ~= nil then
			if protocol == 'imessage' then
				hs.messages.iMessage(phone, message)
			else
				hs.messages.SMS(phone, message)
			end
		end
	end
end

function obj:toggleChooser()
  if obj.chooser then
    if obj.chooser:isVisible() then
      obj.chooser:hide()
    else
      obj.chooser:show()
    end
  end
end

function obj:setContacts()
	output, status = hs.execute('featuredContacts', true)
	names = {}
	phones = {}
	i = 1
	for word in string.gmatch(output, '([^,]+)') do
		if string.sub(word, 1, 1) == ' ' then
			word = string.sub(word, 2, string.len(word))
		end
		word = string.gsub(word, '\n', '')
		if i % 2 == 0 then
			table.insert(phones, word)
		else
			table.insert(names, word)
		end
		i = i + 1
	end
	contacts = {}
	for i = 1, tablelength(names) do
		table.insert(contacts, {
			name = names[i],
			phone = phones[i]
		})
	end
	table.sort(contacts, function(a, b)
		return a.name > b.name
	end)
	hs.settings.set('contacts', contacts)
end

function obj:setShortcuts()
	if settingExists('contacts') == nil then
		obj:setContacts()
	end
	choices = {}
	itemCount = 0
  for i, shortcut in ipairs(hs.settings.get('contacts')) do
		for x = 1, 2 do
			skip = false
			if x == 2 and string.lower(string.sub(shortcut.name, 1, 1)) ~= 'k' then
				skip = true
			end
			workingPre = '☎️'
			workingProtocol = 'tel'
			if x == 2 then
				workingProtocol = 'imessage'
				workingPre = '✉️'
			end
			if skip ~= true then
				table.insert(choices,{
					text = workingPre .. ' ' .. shortcut.name,
					phone = shortcut.phone,
					protocol = workingProtocol
				})
				itemCount = itemCount + 1
			end
		end
  end
  if itemCount == 0 then
    obj.chooser:cancel()
  else
    obj.chooser:width(30)
    obj.chooser:rows(itemCount)
    obj.chooser:choices(choices)
  end
end

function obj:bindHotkeys(mapping)
  local def = {
    toggleChooser = hs.fnutils.partial(self.toggleChooser, self)
  }
  hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:init()

	self.chooser = hs.chooser.new(function(choice)
		if choice then
			if choice.protocol == 'imessage' then
				textPhone(choice.phone, choice.text, choice.protocol)()
			else
				callPhone(choice.phone, choice.protocol)()
			end
		end
	end)

	self:setShortcuts()

end

return obj
