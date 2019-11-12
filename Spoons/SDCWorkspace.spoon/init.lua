--- === SDC Workspace ===
local obj = {}
obj.__index = obj
obj.name = "SDCWorkspace"

local function activateWorkspace(itemTitle, show, focus, hide, quit)
	return function()
		obj:quitApps(quit)
    obj:hideApps(hide)
		obj:openApps(show)
		obj:focusApps(focus)
    hs.alert.show(itemTitle, 0.5)
  end
end

function obj:openApps(apps)
	if apps == nil then return end
  for i, app in ipairs(apps) do
    hs.application.launchOrFocus(app)
  end
end

function obj:focusApps(apps)
	if apps == nil then return end
  for i, app in ipairs(apps) do
    hs.application.launchOrFocus(app)
  end
end

function obj:hideApps(apps)
	if apps == nil then return end
  for i, app in ipairs(apps) do
    thisApp = hs.application.find(app)
    if thisApp ~= nil then
      thisApp:hide()
    end
  end
end

function obj:quitApps(apps)
	if apps == nil then return end
  for i, app in ipairs(apps) do
    thisApp = hs.application.find(app)
    if thisApp ~= nil then
      thisApp:kill()
    end
  end
end

function obj:setWorkspaces()
	obj.chooser = hs.chooser.new(function(choice)
		if choice then
			activateWorkspace(choice.text, choice.show, choice.focus, choice.hide, choice.quit)()
		end
	end)
  choices = {}
  itemCount = 0
  for i, workspace in ipairs(obj.workspaces) do
    choice = {}
    choice.text = workspace.title
		choice.show = workspace.show
		choice.focus = workspace.focus
    choice.hide = workspace.hide
    choice.quit = workspace.quit
    table.insert(choices, choice)
    itemCount = itemCount + 1
  end
	if itemCount == 0 then
		print('none')
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
	hs.timer.doAfter(1, function()
		self:setWorkspaces()
	end)
end

return obj
