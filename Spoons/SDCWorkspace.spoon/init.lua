--- === SDC Workspace ===
local obj = {}
obj.__index = obj
obj.name = "SDCWorkspace"

local function activateWorkspace(itemTitle, softToggleOpen, softToggleClose, hardToggle)
  return function()
    obj:hideApps(softToggleClose)
    obj:openApps(softToggleOpen)
    obj:openApps(hardToggle)
    hs.alert.show(itemTitle)
  end
end

function obj:openApps(apps)
  for i, app in ipairs(apps) do
    hs.application.launchOrFocus(app)
  end
end

function obj:hideApps(apps)
  for i, app in ipairs(apps) do
    thisApp = hs.application.find(app)
    if thisApp ~= nil then
      thisApp:hide()
    end
  end
end

function obj:closeApps(apps)
  for i, app in ipairs(apps) do
    thisApp = hs.application.find(app)
    if thisApp ~= nil then
      thisApp:kill()
    end
  end
end

function obj:setWorkspaces(workspaces)
  obj.workspaces = workspaces
  menuItems = {}
  choices = {}
  itemCount = 0
  for i, workspace in ipairs(workspaces) do
    menuItem = {}
    choice = {}
    menuItem.title = workspace.title
    choice.text = workspace.title
    menuItem.fn = activateWorkspace(menuItem.title, workspace.softToggleOpen, workspace.softToggleClose, workspace.hardToggle)
    choice.softToggleOpen = workspace.softToggleOpen
    choice.softToggleClose = workspace.softToggleClose
    choice.hardToggle = workspace.hardToggle
    table.insert(menuItems, menuItem)
    table.insert(choices, choice)
    itemCount = itemCount + 1
  end
  obj.menuWorkspace:setMenu(menuItems)
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

  self.menuWorkspace = hs.menubar.new():setTitle('🏢')
  self.chooser = hs.chooser.new(function(choice)
    activateWorkspace(choice.text, choice.softToggleOpen, choice.softToggleClose, choice.hardToggle)()
  end)

end

return obj
