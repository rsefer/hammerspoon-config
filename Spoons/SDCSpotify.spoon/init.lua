--- === SDC Spotify ===
local obj = {}
obj.__index = obj
obj.name = "SDCSpotify"

function obj:setSpotifyMenusText()
  if obj.spotifyControlMenu then
    if hs.spotify:isPlaying() then
      obj.spotifyControlMenu:setTitle("❚❚")
    else
      obj.spotifyControlMenu:setTitle("▶")
    end
  end
  if obj.spotifyTitleMenu and hs.spotify.getCurrentArtist() and hs.spotify.getCurrentTrack() then
    obj.spotifyTitleMenu:setTitle(hs.spotify.getCurrentArtist() .. ' - ' .. '"' .. hs.spotify.getCurrentTrack() .. '"')
  end
end

function obj:loadSpotifyMenus()
  obj.spotifyTitleMenu = hs.menubar.new():setClickCallback(obj.openSpotify)
  obj.spotifyControlMenu = hs.menubar.new():setClickCallback(obj.spotifyTogglePlayPause)
  obj:setSpotifyMenusText()
end

function obj:unloadSpotifyMenus()
  if obj.spotifyControlMenu then
    obj.spotifyControlMenu:removeFromMenuBar():delete()
  end
  if obj.spotifyTitleMenu then
    obj.spotifyTitleMenu:removeFromMenuBar():delete()
  end
end

function obj:spotifyTogglePlayPause()
  hs.spotify.playpause()
  obj:setSpotifyMenusText()
end

function obj:openSpotify()
  hs.application.launchOrFocus('Spotify')
end

function obj:init()
  if hs.spotify.isRunning() then
    self.loadSpotifyMenus()
  end
  obj.spotifyTimer = hs.timer.doEvery(2, function()
    if hs.spotify:isRunning() then
      obj.setSpotifyMenusText()
    end
  end):stop()
end

function obj:start()

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
