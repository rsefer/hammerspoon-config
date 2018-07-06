--- === SDC iTunes ===
local obj = {}
obj.__index = obj
obj.name = "SDCItunes"

function script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  return str:match("(.*/)")
end

local iconSize = 14.0
local icon = hs.image.imageFromPath(script_path() .. 'images/itunes_red.pdf'):setSize({ w = iconSize, h = iconSize })
local iconPlay = hs.image.imageFromPath(script_path() .. 'images/play.pdf'):setSize({ w = iconSize, h = iconSize })
local iconPause = hs.image.imageFromPath(script_path() .. 'images/pause.pdf'):setSize({ w = iconSize, h = iconSize })

function songString(artist, track)
  return artist .. ' - ' .. '"' .. track .. '"'
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function obj:setPlayerMenus()
  if obj.playerControlMenu then
    if hs.itunes:isPlaying() then
      obj.playerControlMenu:setIcon(iconPause)
    else
      obj.playerControlMenu:setIcon(iconPlay)
    end
  end
  if obj.playerTitleMenu and hs.itunes.getCurrentArtist() and hs.itunes.getCurrentTrack() then
    newSongString = songString(hs.itunes.getCurrentArtist(), hs.itunes.getCurrentTrack())
    obj.currentSongPosition = hs.itunes.getPosition()

    if newSongString ~= obj.currentSong then
      obj.currentSongDuration = hs.itunes.getDuration()

      if hs.itunes:isPlaying() then
        if obj.showAlerts then
          hs.alert.closeSpecific(obj.currentSongAlertUUID, 0)
          obj.currentSongAlertUUID = hs.alert.show("🎵 " .. newSongString, {
            fillColor = {
              white = 0,
              alpha = 0
            },
            strokeColor = {
              white = 1,
              alpha = 0
            },
            strokeWidth = 0,
            textColor = {
              white = 0,
              alpha = 1
            },
            textSize = 10,
            radius = 10,
            atScreenEdge = 1
          }, 5)
        end
        if obj.showNotifications then
          local notification = hs.notify.new({ title = hs.itunes.getCurrentTrack(), subTitle = 'Artist: ' .. hs.itunes.getCurrentArtist(), informativeText = 'Album: ' .. hs.itunes.getCurrentAlbum() })
          notification:setIdImage(hs.image.imageFromAppBundle('com.apple.iTunes'))
          notification:send()
          hs.timer.doAfter(2.5, function() notification:withdraw() end)
        end
      end

    end

    if obj.screenClass ~= 'small' and obj.showCurrentSongProgressBar then
      currentSongPositionPercentage = obj.currentSongPosition / obj.currentSongDuration

      fontCharacterWidth = 8
      menubarHeight = 22
      titleWidth = (string.len(newSongString)) * fontCharacterWidth
      if titleWidth > 250 then
        barWidth = 250
      else
        barWidth = titleWidth
      end

      obj.menubarCanvas = hs.canvas.new({ x = 0, y = 0, h = menubarHeight, w = barWidth })
        :appendElements({
          id = 'songProgress',
          type = 'rectangle',
          action = 'fill',
          frame = {
            x = '0%',
            y = menubarHeight - 2,
            h = 2,
            w = round(currentSongPositionPercentage * 100, 2) .. '%'
          },
          fillColor = { ['hex'] = 'f46060' }
        },
        {
          id = 'songText',
          type = 'text',
          text = newSongString:gsub(' ', ' '), -- replace 'normal space' character with 'en space',
          textSize = 14,
          textLineBreak = 'truncateTail',
          textColor = { black = 1.0 },
          textFont = 'Courier',
          frame = { x = '0%', y = 1, h = '100%', w = '100%' }
        })

      obj.playerTitleMenu:setIcon(obj.menubarCanvas:imageFromCanvas(), false)
    end

    obj.currentSong = newSongString
  end
end

function obj:unloadPlayerMenus()
  obj.playerControlMenu:setIcon(nil)
  obj.playerTitleMenu:setIcon(nil)
  if obj.currentSongProgressBar then
    obj.currentSongProgressBar:delete()
  end
end

function obj:playerTogglePlayPause()
  hs.itunes.playpause()
  obj:setPlayerMenus()
end

function obj:togglePlayer()
  playerApp = hs.application.find('iTunes')
  if hs.itunes:isRunning() and playerApp:isFrontmost() then
    playerApp:hide()
  else
    hs.application.launchOrFocus('iTunes')
  end
end

function obj:init()

  self.computerName = hs.host.localizedName()
  self.screenClass = 'large' -- assumes large iMac
  if string.match(string.lower(self.computerName), 'macbook') then
    self.screenClass = 'small'
  end

  self.showCurrentSongProgressBar = true
  self.showNotifications = false
  self.showAlerts = false

  self.playerTitleMenu = hs.menubar.new():setClickCallback(obj.togglePlayer)
  self.playerControlMenu = hs.menubar.new():setClickCallback(obj.playerTogglePlayPause)
  obj:setPlayerMenus()

  self.playerMenu = hs.menubar.new()
    :setClickCallback(obj.togglePlayer)
    :setIcon(icon, true)

  self.playerTimer = hs.timer.doEvery(0.5, function()
    if hs.itunes:isRunning() then
      obj:setPlayerMenus()
      if hs.itunes:isPlaying() then
        obj.playerMenu:setIcon(icon, false)
      else
        obj.playerMenu:setIcon(icon, true)
      end
    end
  end):stop()
end

function obj:start()

  obj.currentSong = ''
  obj.currentSongDuration = 0
  obj.currentSongPosition = 0
  obj.playerTimer:start()

  obj.watcher = hs.application.watcher.new(function(name, event, app)
    if name == 'iTunes' then
      if event == 2 or event == hs.application.watcher.terminated then
        obj.playerTimer:stop()
        obj:unloadPlayerMenus()
        obj.playerMenu:setIcon(icon, true)
      elseif event == 1 or event == hs.application.watcher.launched then
        obj.playerTimer:start()
      end
    end
  end):start()

  return self

end

function obj:stop()
  obj.applicationWatcher:stop()
  obj.playerTimer:stop()
  return self
end

return obj
