--- === SDC Overcast ===
local obj = {}
obj.__index = obj
obj.name = "SDCOvercast"

require 'common'

local overcastWebviewHome = 'https://overcast.fm/podcasts'
local viewWidth = 350
local viewHeight = 400
local iconSize = 14.0
local icon = hs.image.imageFromPath(script_path() .. 'images/overcast_orange.pdf'):setSize({ w = iconSize, h = iconSize })

local idname = 'id' .. hs.host.uuid():gsub('-', '')
local js = hs.webview.usercontent.new(idname)
localjsScript = "if (window.location.href == 'https://overcast.fm/podcasts') { setTimeout(function() { location.reload(); }, 60 * 1000); } $('.navlink:eq(1), #speedcontrols').css('display', 'none'); $('h2.ocseparatorbar:first()').css('margin-top', '0px'); if ($('#audioplayer').length > 0) { $('.titlestack').prev().removeClass('marginbottom1').css('margin-bottom', '8px'); $('#progressbar').css('margin-top', '8px'); $('.fullart_container').css('float', 'left').css('width', '20%'); $('#speedcontrols').next().css('font-size', '12px').css('clear', 'both').css('margin-top', '20px'); $('#playcontrols_container').css('margin', '13px 0px 13px 20%').css('width', '80%'); } " .. "setInterval(function() { var isAudioPlaying = false; if ($('#audioplayer').length > 0 && !$('#audioplayer').prop('paused')) { isAudioPlaying = true; } webkit.messageHandlers." .. idname .. ".postMessage({ isPlaying: isAudioPlaying }); }, 3000);"
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
