--- === SDC Spotify ===
local obj = {}
obj.__index = obj
obj.name = "SDCSpotify"

function script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  return str:match("(.*/)")
end

local iconSize = 14.0
local icon = hs.image.imageFromPath(script_path() .. 'images/spotify_green.pdf'):setSize({ w = iconSize, h = iconSize })
local iconPlay = hs.image.imageFromPath(script_path() .. 'images/play.pdf'):setSize({ w = iconSize, h = iconSize })
local iconPause = hs.image.imageFromPath(script_path() .. 'images/pause.pdf'):setSize({ w = iconSize, h = iconSize })

function songString(artist, track)
  return artist .. ' - ' .. '"' .. track .. '"'
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function obj:setSpotifyMenus()
  if obj.spotifyControlMenu then
    if hs.spotify:isPlaying() then
      obj.spotifyControlMenu:setIcon(iconPause)
    else
      obj.spotifyControlMenu:setIcon(iconPlay)
    end
  end
  if obj.spotifyTitleMenu and hs.spotify.getCurrentArtist() and hs.spotify.getCurrentTrack() then
    newSongString = songString(hs.spotify.getCurrentArtist(), hs.spotify.getCurrentTrack())
    obj.currentSongPosition = hs.spotify.getPosition()

    if newSongString ~= obj.currentSong then
      obj.currentSongDuration = hs.spotify.getDuration()

      if hs.spotify:isPlaying() then
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
          local notification = hs.notify.new({ title = hs.spotify.getCurrentTrack(), subTitle = 'Artist: ' .. hs.spotify.getCurrentArtist(), informativeText = 'Album: ' .. hs.spotify.getCurrentAlbum() })
          notification:setIdImage(hs.image.imageFromAppBundle('com.spotify.client'))
          notification:send()
          hs.timer.doAfter(2.5, function() notification:withdraw() end)
        end
      end

    end

    if obj.showCurrentSongProgressBar then
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
          fillColor = { ['hex'] = '1db954' }
        },
        {
          id = 'songText',
          type = 'text',
          text = newSongString,
          textSize = 14,
          textLineBreak = 'truncateTail',
          textColor = { black = 1.0 },
          textFont = 'Courier',
          frame = { x = '0%', y = 1, h = '100%', w = '100%' }
        })

      obj.spotifyTitleMenu:setIcon(obj.menubarCanvas:imageFromCanvas(), false)
    end

    obj.currentSong = newSongString
  end
end

function obj:unloadSpotifyMenus()
  obj.spotifyControlMenu:setIcon(nil)
  obj.spotifyTitleMenu:setIcon(nil)
  if obj.currentSongProgressBar then
    obj.currentSongProgressBar:delete()
  end
end

function obj:spotifyTogglePlayPause()
  hs.spotify.playpause()
  obj:setSpotifyMenus()
end

function obj:toggleSpotify()
  spotifyApp = hs.application.find('Spotify')
  if hs.spotify:isRunning() and spotifyApp:isFrontmost() then
    spotifyApp:hide()
  else
    hs.application.launchOrFocus('Spotify')
  end
end

function obj:init()
  self.showCurrentSongProgressBar = true
  self.showNotifications = true
  self.showAlerts = false

  self.spotifyTitleMenu = hs.menubar.new():setClickCallback(obj.toggleSpotify)
  self.spotifyControlMenu = hs.menubar.new():setClickCallback(obj.spotifyTogglePlayPause)
  obj:setSpotifyMenus()

  self.spotifyMenu = hs.menubar.new()
    :setClickCallback(obj.toggleSpotify)
    :setIcon(icon, true)

  self.spotifyTimer = hs.timer.doEvery(0.5, function()
    if hs.spotify:isRunning() then
      obj:setSpotifyMenus()
      if hs.spotify:isPlaying() then
        obj.spotifyMenu:setIcon(icon, false)
      else
        obj.spotifyMenu:setIcon(icon, true)
      end
    end
  end):stop()
end

function obj:start()

  obj.currentSong = ''
  obj.currentSongDuration = 0
  obj.currentSongPosition = 0
  obj.spotifyTimer:start()

  obj.watcher = hs.application.watcher.new(function(name, event, app)
    if name == 'Spotify' then
      if event == 2 or event == hs.application.watcher.terminated then
        obj.spotifyTimer:stop()
        obj:unloadSpotifyMenus()
        obj.spotifyMenu:setIcon(icon, true)
      elseif event == 1 or event == hs.application.watcher.launched then
        obj.spotifyTimer:start()
      end
    end
  end):start()

  return self

end

function obj:stop()
  obj.applicationWatcher:stop()
  obj.spotifyTimer:stop()
  return self
end

return obj
