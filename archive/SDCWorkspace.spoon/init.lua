--- === SDC Workspace ===
local obj = {}
obj.__index = obj
obj.name = "SDCWorkspace"

function activateWorkspace(itemTitle, show, focus, hide, quit)
	return function()
		obj:actionOnApps(quit, 'quit')
		obj:actionOnApps(hide, 'hide')
		obj:actionOnApps(show, 'show')
		obj:actionOnApps(focus, 'focus')
    hs.alert.show(itemTitle, 0.5)
  end
end

function obj:actionOnApps(apps, action)
	if not apps then return end
	for i, app in ipairs(apps) do
		if action == 'open' or action == 'focus' then
			hs.application.launchOrFocus(app)
		elseif action == 'hide' or action == 'quit' then
			thisApp = hs.application.get(app)
			if thisApp ~= nil then
				if action == 'hide' then
					thisApp:hide()
				elseif action == 'quit' then
					thisApp:kill()
				end
			end
		end
	end
end

function obj:setWorkspaces()
  choices = {}
  for i, workspace in ipairs(obj.workspaces) do
    choice = {}
    choice.text = workspace.title
		choice.show = workspace.show
		choice.focus = workspace.focus
    choice.hide = workspace.hide
    choice.quit = workspace.quit
		if workspace.symbol then
			choice.image = textToImage(workspace.symbol)
		end
    table.insert(choices, choice)
  end
	if tablelength(choices) == 0 then
    obj.chooser:cancel()
  else
    obj.chooser:width(30)
    obj.chooser:rows(tablelength(choices))
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
  hs.spoons.bindHotkeysToSpec({
    toggleChooser = hs.fnutils.partial(self.toggleChooser, self)
  }, mapping)
end

function obj:init()

	self.chooser = hs.chooser.new(function(choice)
		if not choice then return end
		activateWorkspace(choice.text, choice.show, choice.focus, choice.hide, choice.quit)()
		spoon.SDCWindows:resetAllApps()
	end)

end

function obj:start()
	self:setWorkspaces()
end

return obj
