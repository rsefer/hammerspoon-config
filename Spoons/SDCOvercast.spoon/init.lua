--- === SDC Overcast ===
local obj = {}
obj.__index = obj
obj.name = "SDCOvercast"

function script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  return str:match("(.*/)")
end

local overcastWebviewHome = 'https://overcast.fm/podcasts'
local viewWidth = 350
local viewHeight = 400
local iconSize = 14.0
local icon = hs.image.imageFromPath(script_path() .. 'images/overcast_orange.pdf'):setSize({ w = iconSize, h = iconSize })

local js = hs.webview.usercontent.new('idhsovercastwebview')
local injectFileResult = ''
for line in io.lines(script_path() .. "inject.js") do injectFileResult = injectFileResult .. line end
localjsScript = "var thome = '" .. overcastWebviewHome .. "';" .. injectFileResult
js:injectScript({ source = localjsScript, mainFrame = true, injectionTime = 'documentEnd' }):setCallback(function(message)
  if message.body.isPlaying then
    obj.overcastMenu:setIcon(icon, false)
  else
    obj.overcastMenu:setIcon(icon, true)
  end
end)

function obj:toggleWebview()
  if obj.isShown then
    obj.overcastWebview:hide()
    obj.isShown = false
  else
    obj.overcastWebview:show():bringToFront(true)
    obj.isShown = true
  end
end

function obj:init()

  self.isShown = false

  self.overcastToolbar = hs.webview.toolbar.new('myConsole', { { id = 'resetBrowser', label = 'Home', fn = function(t, w, i) self.overcastWebview:url(overcastWebviewHome) end } })
    :sizeMode('small')
    :displayMode('label')

  self.overcastMenu = hs.menubar.new()
    :setClickCallback(obj.toggleWebview)
    :setIcon(icon, true)

  self.overcastMenuFrame = self.overcastMenu:frame()
  self.rect = hs.geometry.rect((self.overcastMenuFrame.x + self.overcastMenuFrame.w / 2) - (viewWidth / 2), self.overcastMenuFrame.y, viewWidth, viewHeight)

  self.overcastWebview = hs.webview.newBrowser(self.rect, { developerExtrasEnabled = true }, js)
    :url(overcastWebviewHome)
    :allowTextEntry(true)
    :shadow(true)
    :attachedToolbar(self.overcastToolbar)

end

return obj
