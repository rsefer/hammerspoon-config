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
	asBool, asObject, asDesc = hs.osascript.applescript([[
		tell application "Contacts"
			set featuredPeople to {}
			repeat with p in people in group "Featured"
				copy {nickname of p, value of phone 1 of p} to the end of featuredPeople
			end repeat
			featuredPeople
		end tell
	]])
	contacts = {}
	for x, person in ipairs(asObject) do
		table.insert(contacts, {
			name = person[1],
			phone = person[2]
		})
	end
	table.sort(contacts, function(a, b)
		return a.name > b.name
	end)
	hs.settings.set('contacts', contacts)
end

function obj:setShortcuts()
	if not settingExists('contacts') then
		obj:setContacts()
	end
	choices = {}
  for i, shortcut in ipairs(hs.settings.get('contacts')) do
		for x = 1, 2 do
			skip = false
			if x == 2 and string.lower(string.sub(shortcut.name, 1, 1)) ~= 'k' then
				skip = true
			end
			imageSymbol = '☎️'
			workingProtocol = 'tel'
			if x == 2 then
				workingProtocol = 'imessage'
				imageSymbol = '✉️'
			end
			if skip ~= true then
				table.insert(choices, {
					text = shortcut.name,
					phone = shortcut.phone,
					protocol = workingProtocol,
					image = textToImage(imageSymbol)
				})
			end
		end
  end
  if #choices == 0 then
    obj.chooser:cancel()
  else
    obj.chooser:width(30)
    obj.chooser:rows(#choices)
    obj.chooser:choices(choices)
  end
end

function obj:bindHotkeys(mapping)
  hs.spoons.bindHotkeysToSpec({
    toggleChooser = hs.fnutils.partial(self.toggleChooser, self)
  }, mapping)
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
