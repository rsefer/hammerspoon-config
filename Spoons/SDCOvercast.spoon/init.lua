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
local iconPlay = hs.image.imageFromPath(script_path() .. 'images/play.pdf'):setSize({ w = iconSize, h = iconSize })
local iconPause = hs.image.imageFromPath(script_path() .. 'images/pause.pdf'):setSize({ w = iconSize, h = iconSize })

function obj:togglePlayPause()
  obj.overcastWebview:evaluateJavaScript('togglePlayPause();')
end

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
  self.showProgressBar = true
  self.hideSpotify = true

  self.overcastToolbar = hs.webview.toolbar.new('myConsole', { { id = 'resetBrowser', label = 'Home', fn = function(t, w, i) self.overcastWebview:url(overcastWebviewHome) end } })
    :sizeMode('small')
    :displayMode('label')

  self.overcastInfoMenu = hs.menubar.new()
    :setClickCallback(obj.toggleWebview)
  self.overcastControlMenu = hs.menubar.new()
    :setClickCallback(obj.togglePlayPause)

  self.overcastMenu = hs.menubar.new()
    :setClickCallback(obj.toggleWebview)
    :setIcon(icon, true)

  self.overcastMenuFrame = self.overcastMenu:frame()
  self.rect = hs.geometry.rect((self.overcastMenuFrame.x + self.overcastMenuFrame.w / 2) - (viewWidth / 2), self.overcastMenuFrame.y, viewWidth, viewHeight)

  self.overcastJS = hs.webview.usercontent.new('idhsovercastwebview')

  local injectFileResult = ''
  for line in io.lines(script_path() .. "inject.js") do injectFileResult = injectFileResult .. line end

  localjsScript = "var thome = '" .. overcastWebviewHome .. "';" .. injectFileResult
  self.overcastJS:injectScript({ source = localjsScript, mainFrame = true, injectionTime = 'documentEnd' })
    :setCallback(function(message)

      if message.body.page == 'home' or message.body.progress >= 1 then
        obj.overcastInfoMenu:setIcon(nil)
        obj.overcastMenu:setIcon(icon, true)
      else

        if message.body.isPlaying then

          obj.overcastControlMenu:setIcon(iconPause)
          obj.overcastMenu:setIcon(icon, false)

          if obj.hideSpotify then
            if hs.spotify.isPlaying() then
              hs.spotify.pause()
            end
          end

        else
          obj.overcastControlMenu:setIcon(iconPlay)
          obj.overcastMenu:setIcon(icon, true)
        end

        if obj.showProgressBar then

          local episodeString = message.body.podcast.name .. ' - ' .. message.body.podcast.episodeTitle

          menubarHeight = 22

          obj.menubarCanvas = hs.canvas.new({ x = 0, y = 0, h = menubarHeight, w = 250 })
            :appendElements({
              id = 'songProgress',
              type = 'rectangle',
              action = 'fill',
              frame = {
                x = '0%',
                y = menubarHeight - 2,
                h = 2,
                w = round(message.body.progress * 100, 2) .. '%'
              },
              fillColor = { ['hex'] = 'fc7e0f' }
            },
            {
              id = 'songText',
              type = 'text',
              text = episodeString:gsub(' ', ' '), -- replace 'normal space' character with 'en space'
              textSize = 14,
              textLineBreak = 'truncateTail',
              textColor = { black = 1.0 },
              textFont = 'Courier',
              frame = { x = '0%', y = 1, h = '100%', w = '100%' }
            })

          obj.overcastInfoMenu:setIcon(obj.menubarCanvas:imageFromCanvas(), false)
        end

      end

    end)

  self.overcastWebview = hs.webview.newBrowser(self.rect, { developerExtrasEnabled = true }, self.overcastJS)
    :url(overcastWebviewHome)
    :allowTextEntry(true)
    :shadow(true)
    :attachedToolbar(self.overcastToolbar)

end

return obj
