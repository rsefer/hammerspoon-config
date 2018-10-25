--- === SDC Dash ===
local obj = {}
obj.__index = obj
obj.name = "SDCDash"

function script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  return str:match("(.*/)")
end

local viewWidth = 500
local viewHeight = 700

function obj:toggleWebview()
  if obj.isShown then
    obj.dashWebview:hide():delete()
    obj.isShown = false
  else

		local injectFileResult = ''
	  for line in io.lines(script_path() .. "inject.js") do injectFileResult = injectFileResult .. line end
		localjsScript = injectFileResult
		obj.dashJS = hs.webview.usercontent.new('idhsdashwebview')
	  obj.dashJS:injectScript({ source = localjsScript, mainFrame = true, injectionTime = 'documentEnd' })
	    :setCallback(function(message)

	      if message.body.isLink == true then
					hs.urlevent.openURL(message.body.linkTarget)
					obj.dashWebview:hide()
					obj.isShown = false
				end

	    end)

		local screenMode = hs.window.focusedWindow():screen():currentMode()
		obj.rect = hs.geometry.rect(screenMode.w - viewWidth, 0, viewWidth, viewHeight)
		obj.dashWebview = hs.webview.newBrowser(self.rect, { developerExtrasEnabled = true }, obj.dashJS)
	    :url(obj.dashWebviewHome)
	    :allowTextEntry(true)
	    :shadow(true)
			:show()
			:bringToFront(true)
    obj.isShown = true
  end
end

function obj:bindHotkeys(mapping)
  local def = {
    toggleWebview = hs.fnutils.partial(self.toggleWebview, self)
  }
  hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:setConfig(dashHomeURL)
  obj.dashWebviewHome = dashHomeURL
end

function obj:init()
  self.isShown = false
end

return obj
