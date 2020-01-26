--- === SDC Phone ===
local obj = {}
obj.__index = obj
obj.name = "SDCPhone"

local function callNumber(number, protocol)
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
			do shell script "open ]] .. protocol .. [[://" & quoted form of "]] .. number .. workingParam .. [["
			tell application "System Events"
				repeat while not (button "Call" of window 1 of application process "FaceTime" exists)
					delay 1
				end repeat
				click button "Call" of window 1 of application process "FaceTime"
			end tell
		]])
		-- hs.osascript.applescript('open location "tel://' .. number .. '?audio=yes"')
		-- hs.urlevent.openURL('tel://' .. number ..'?audio=yes')
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

function obj:setShortcuts()
	choices = {}
	itemCount = 0
  for i, shortcut in ipairs(obj.phoneNumbers) do
		choice = {}
		pre = '☎️'
		if shortcut.protocol == 'facetime' then
			pre = '📽'
		end
    choice.text = pre .. ' ' .. shortcut.text
		choice.number = shortcut.number
		choice.protocol = shortcut.protocol
    table.insert(choices, choice)
    itemCount = itemCount + 1
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
			callNumber(choice.number, choice.protocol)()
		end
	end)

end

return obj
