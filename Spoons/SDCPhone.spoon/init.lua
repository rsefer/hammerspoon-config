--- === SDC Phone ===
local obj = {}
obj.__index = obj
obj.name = "SDCPhone"

local function callNumber(number)
	return function()
		hs.osascript.applescript('open location "tel://' .. number .. '?audio=yes"')
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
    choice.text = shortcut.text
		choice.number = shortcut.number
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
			callNumber(choice.number)()
		end
	end)

end

return obj
