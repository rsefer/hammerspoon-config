--- === SDC Workspace ===
local obj = {}
obj.__index = obj
obj.name = "SDC-Workspace"

require 'common'

local menuWork = hs.menubar.new()

function menu_item_callback(currentStatus, openOnly, openClose, hide)
  return function()
    if currentStatus then
      closeApps(openClose)
    else
      openApps(openOnly)
      openApps(openClose)
      hideApps(hide)
    end
  end
end

function openApps(apps)
  for i, app in ipairs(apps) do
    hs.application.launchOrFocus(app)
  end
end

function hideApps(apps)
  for i, app in ipairs(apps) do
    thisApp = hs.application.find(app)
    if thisApp ~= nil then
      thisApp:hide()
    end
  end
end

function closeApps(apps)
  for i, app in ipairs(apps) do
    thisApp = hs.application.find(app)
    if thisApp ~= nil then
      thisApp:kill()
    end
  end
end

local menu_items = {
  {
    title = 'Code',
    menu = {
      {
        title = 'Close',
        fn = menu_item_callback(true, {},
        {
          'GitHub Desktop',
          'Atom',
          'Terminal'
        },
        {})
      }
    },
    fn = menu_item_callback(false, {
      'Google Chrome'
    },
    {
      'GitHub Desktop',
      'Atom',
      'Terminal'
    },
    {
      'Tweetbot',
      'Messages'
    })
  }
}

menuWork:setTitle('W')
menuWork:setMenu(menu_items)

return obj
