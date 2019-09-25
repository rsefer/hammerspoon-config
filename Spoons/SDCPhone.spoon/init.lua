--- === SDC Phone ===
local obj = {}
obj.__index = obj
obj.name = "SDCPhone"

function script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  return str:match("(.*/)")
end

local function callNumber(number)
	return function()
		hs.applescript('open location "tel://' .. number .. '?audio=yes"')
		-- hs.urlevent.openURL('tel://' .. number ..'?audio=yes')
  end
end

function obj:setShortcuts(shortcuts)
  obj.numbers = shortcuts
  menuItems = {}
  choices = {}
  itemCount = 0
  for i, shortcut in ipairs(shortcuts) do
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

function obj:toggleChooser()
  if obj.chooser then
    if obj.chooser:isVisible() then
      obj.chooser:hide()
    else
      obj.chooser:show()
    end
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
    callNumber(choice.number)()
  end)

end

return obj
