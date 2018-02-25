--- === SDC Workspace ===
local obj = {}
obj.__index = obj
obj.name = "SDCWorkspace"

local function menu_item_callback(itemTitle, softToggleOpen, softToggleClose, hardToggle)
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
  for i, workspace in ipairs(workspaces) do
    menuItem = {}
    menuItem.title = workspace.title
    menuItem.fn = menu_item_callback(menuItem.title, workspace.softToggleOpen, workspace.softToggleClose, workspace.hardToggle)
    table.insert(menuItems, menuItem)
  end
  obj.menuWorkspace:setMenu(menuItems)
end

function obj:init()
  self.menuWorkspace = hs.menubar.new():setTitle('W')
end

return obj
