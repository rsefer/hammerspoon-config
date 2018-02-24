--- === SDC Spotify ===
local obj = {}
obj.__index = obj
obj.name = "SDCSpotify"

local spotifyControlMenu = nil
local spotifyTitleMenu = nil
local spotifyTimer = nil

function spotifyTimerSet()
  spotifyTimer = hs.timer.doEvery(2, function()
    if hs.spotify:isRunning() then
      setSpotifyMenusText()
    end
  end)
end

function setSpotifyMenusText()
  if spotifyControlMenu then
    if hs.spotify:isPlaying() then
      spotifyControlMenu:setTitle("❚❚")
    else
      spotifyControlMenu:setTitle("▶")
    end
  end
  if spotifyTitleMenu and hs.spotify.getCurrentArtist() and hs.spotify.getCurrentTrack() then
    spotifyTitleMenu:setTitle(hs.spotify.getCurrentArtist() .. ' - ' .. '"' .. hs.spotify.getCurrentTrack() .. '"')
  end
end

function loadSpotifyMenus()
  spotifyTitleMenu = hs.menubar.new():setClickCallback(openSpotify)
  spotifyControlMenu = hs.menubar.new():setClickCallback(spotifyTogglePlayPause)
end

function spotifyTogglePlayPause()
  hs.spotify.playpause()
  setSpotifyMenusText()
end

function openSpotify()
  hs.application.launchOrFocus('Spotify')
end

if hs.spotify.isRunning() then
  loadSpotifyMenus()
  spotifyTimerSet()
end

hs.application.watcher.new(function(name, event, app)
  if name == 'Spotify' then
    if event == hs.application.watcher.terminated then
      if spotifyTimer then
        spotifyTimer = spotifyTimer:stop() and nil
      end
      if spotifyControlMenu then
        spotifyControlMenu:removeFromMenuBar():delete()
      end
      if spotifyTitleMenu then
        spotifyTitleMenu:removeFromMenuBar():delete()
      end
    elseif event == hs.application.watcher.launched then
      loadSpotifyMenus()
      spotifyTimerSet()
    end
  end
end):start()

return obj
