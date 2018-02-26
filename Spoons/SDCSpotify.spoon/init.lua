--- === SDC Spotify ===
local obj = {}
obj.__index = obj
obj.name = "SDCSpotify"

function songString(artist, track)
  return artist .. ' - ' .. '"' .. track .. '"'
end

function obj:setSpotifyMenus()
  if obj.spotifyControlMenu then
    if hs.spotify:isPlaying() then
      obj.spotifyControlMenu:setTitle("❚❚")
    else
      obj.spotifyControlMenu:setTitle("▶")
    end
  end
  if obj.spotifyTitleMenu and hs.spotify.getCurrentArtist() and hs.spotify.getCurrentTrack() then
    newSongString = songString(hs.spotify.getCurrentArtist(), hs.spotify.getCurrentTrack())
    obj.spotifyTitleMenu:setTitle(newSongString)
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

      obj.spotifyTitleMenuFrame = obj.spotifyTitleMenu:frame()
      if obj.currentSongProgressBar then
        obj.currentSongProgressBar:delete()
      end
      obj.currentSongProgressBar = hs.drawing.line({
        x = obj.spotifyTitleMenuFrame.x,
        y = obj.spotifyTitleMenuFrame.h - 2
      },
      {
        x = obj.spotifyTitleMenuFrame.x + (obj.spotifyTitleMenuFrame.w * currentSongPositionPercentage),
        y = obj.spotifyTitleMenuFrame.h - 2
      })
      alpha = 1
      -- if currentSongPositionPercentage < 0.1 then
      --   alpha = currentSongPositionPercentage * 10
      -- end
      obj.currentSongProgressBar:setStrokeColor({['hex'] = '1db954', ['alpha'] = alpha})
      obj.currentSongProgressBar:setStrokeWidth(4)
      -- obj.currentSongProgressBar:show()
      if currentSongPositionPercentage > 0.05 then
        -- helps when song title length changes
        obj.currentSongProgressBar:show()
      end
    end

    obj.currentSong = newSongString
  end
end

function obj:loadSpotifyMenus()
  obj.spotifyTitleMenu = hs.menubar.new():setClickCallback(function() hs.application.launchOrFocus('Spotify') end)
  obj.spotifyControlMenu = hs.menubar.new():setClickCallback(obj.spotifyTogglePlayPause)
  obj:setSpotifyMenus()
end

function obj:unloadSpotifyMenus()
  if obj.spotifyControlMenu then
    obj.spotifyControlMenu:removeFromMenuBar():delete()
  end
  if obj.spotifyTitleMenu then
    obj.spotifyTitleMenu:removeFromMenuBar():delete()
    if obj.currentSongProgressBar then
      obj.currentSongProgressBar:delete()
    end
  end
end

function obj:spotifyTogglePlayPause()
  hs.spotify.playpause()
  obj:setSpotifyMenus()
end

function obj:init()
  self.showCurrentSongProgressBar = true
  self.showNotifications = true
  self.showAlerts = false
  if hs.spotify.isRunning() then
    self:loadSpotifyMenus()
  end

  self.spotifyTimer = hs.timer.doEvery(0.5, function()
    if hs.spotify:isRunning() then
      obj:setSpotifyMenus()
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
      elseif event == 1 or event == hs.application.watcher.launched then
        obj:loadSpotifyMenus()
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
