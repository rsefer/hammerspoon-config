--- === SDC Music ===
local obj = {}
obj.__index = obj
obj.name = "SDCMusic"

function songString(artist, track)
  return artist .. ' - ' .. '"' .. track .. '"'
end

function getCurrentPlayerState()
	if obj.playerName == 'Spotify' then
		spotifyPlaybackState = hs.spotify:getPlaybackState()
		workingState = 'paused'
		if spotifyPlaybackState == hs.spotify.state_paused then
			workingState = 'paused'
		elseif spotifyPlaybackState == hs.spotify.state_playing then
			workingState = 'playing'
		elseif spotifyPlaybackState == hs.spotify.state_stopped then
			workingState = 'stopped'
		end
		return workingState
	elseif obj.playerName == 'Music' then
		asBool, asObject, asDesc = hs.osascript.applescript('tell application "Music" to return "" & player state')
		return asObject
	end
end

function getCurrentTrackInfo()
	if obj.playerName == 'Spotify' and hs.spotify:getCurrentTrack() then
		return {
			artist = hs.spotify:getCurrentArtist(),
			album = hs.spotify:getCurrentAlbum(),
			name = hs.spotify:getCurrentTrack(),
			duration = hs.spotify:getDuration(),
			playerPosition = hs.spotify:getPosition()
		}
	elseif obj.playerName == 'Music' then
		ok, asProps = hs.osascript.applescript('tell application "Music" to return {artist of current track, album of current track, name of current track, duration of current track, player position}')
		if asProps ~= nil then
			return {
				artist = asProps[1],
				album = asProps[2],
				name = asProps[3],
				duration = asProps[4],
				playerPosition = asProps[5]
			}
		end
	end
	return {}
end

function obj:setPlayerMenus()
	if obj.isDormant == true then
		obj.playerControlMenu:setIcon(nil)
		obj.playerTitleMenu:setIcon(nil)
		do return end
	end
	currentState = getCurrentPlayerState()


	if currentState == 'playing' then
    obj.playerControlMenu:setIcon(hs.image.imageFromPath(hs.spoons.scriptPath() .. 'images/pause.pdf'):setSize({ w = obj.iconSize, h = obj.iconSize }))
	else
		obj.playerControlMenu:setIcon(hs.image.imageFromPath(hs.spoons.scriptPath() .. 'images/play.pdf'):setSize({ w = obj.iconSize, h = obj.iconSize }))
	end

	currentTrack = getCurrentTrackInfo()
	if obj.playerTitleMenu and currentTrack.artist and currentTrack.name then

		newSongString = songString(currentTrack.artist, currentTrack.name)
    obj.currentSongPosition = currentTrack.playerPosition

		if newSongString ~= obj.currentSong then
			if currentTrack.duration ~= nil then
				obj.currentSongDuration = currentTrack.duration
			else
				obj.currentSongDuration = 300
			end

      if currentState == 'playing' then
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

					workingImage = hs.image.imageFromAppBundle(obj.playerApp:bundleID())

					if setupSetting('discogs_key') and setupSetting('discogs_secret') then
						discogsURL = 'https://api.discogs.com/database/search?query=' .. urlencode(currentTrack.artist .. ' - ' .. currentTrack.album) .. '&per_page=1&page=1&key=' .. hs.settings.get('discogs_key') .. '&secret=' .. hs.settings.get('discogs_secret')
						status, body, headers = hs.http.get(discogsURL)
						if status == 200 then
							json = hs.json.decode(body)
							if json.results and json.results[1] and json.results[1].thumb then
								workingImage = hs.image.imageFromURL(json.results[1].thumb)
							end
						end
					end

					local notification = hs.notify.new(function()
						hs.application.launchOrFocus(obj.playerName)
					end, {
						hasActionButton = true,
						actionButtonTitle = 'Open',
						title = currentTrack.name,
						subTitle = 'Artist: ' .. currentTrack.artist,
						informativeText = 'Album: ' .. currentTrack.album
					})
					if workingImage ~= nil then
						notification:setIdImage(workingImage)
					end
          notification:send()
          hs.timer.doAfter(2.5, function() notification:withdraw() end)
        end
      end

    end

		if hs.settings.get('screenClass') ~= 'small' and obj.showCurrentSongProgressBar then
      currentSongPositionPercentage = obj.currentSongPosition / obj.currentSongDuration

      fontCharacterWidth = 8
      menubarHeight = 22
			titleWidth = (string.len(newSongString)) * fontCharacterWidth
      if titleWidth > 250 then
        barWidth = 250
			else
        barWidth = titleWidth + 1 * fontCharacterWidth
			end

			textColor = '000000'
			fillColor = '1db954'
			if obj.playerName == 'Spotify' then
				fillColor = '1db954'
			elseif obj.playerName == 'Music' then
				fillColor = 'f46060'
			end

			if hs.host.interfaceStyle() == 'Dark' then
				textColor = 'ffffff'
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
					fillColor = { ['hex'] = fillColor }
				},
        {
          id = 'songText',
          type = 'text',
          text = newSongString:gsub(' ', ' '), -- replace 'normal space' character with 'en space'
          textSize = 14,
					textLineBreak = 'truncateTail',
					textColor = { ['hex'] = textColor },
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
	if obj.playerName == 'Spotify' then
		hs.spotify.playpause()
	elseif obj.playerName == 'Music' then
		hs.osascript.applescript('tell application "Music" to playpause')
	end
  obj:setPlayerMenus()
end

function obj:togglePlayer()
  if obj.playerApp ~= nil and obj.playerApp:isRunning() and obj.playerApp:isFrontmost() then
    obj.playerApp:hide()
  else
    hs.application.launchOrFocus(obj.playerName)
  end
end

function obj:init()

	self.playerName = hs.settings.get('musicPlayerName')
	self.playerApp = hs.application.get(self.playerName)
  self.showCurrentSongProgressBar = true
  self.showNotifications = true
	self.showAlerts = false

	self.iconSize = 14.0

	workingIcon = hs.spoons.scriptPath() .. 'images/music_red.pdf'
	if self.playerName == 'Spotify' then
		workingIcon = hs.spoons.scriptPath() .. 'images/spotify_green.pdf'
	elseif self.playerName == 'Music' then
		workingIcon = hs.spoons.scriptPath() .. 'images/music_red.pdf'
	end
	self.icon = hs.image.imageFromPath(workingIcon):setSize({ w = self.iconSize, h = self.iconSize })

  self.playerTitleMenu = hs.menubar.new():setClickCallback(obj.togglePlayer)
  self.playerControlMenu = hs.menubar.new():setClickCallback(obj.playerTogglePlayPause)

  self.playerMenu = hs.menubar.new()
    :setClickCallback(obj.togglePlayer)
		:setIcon(self.icon, true)

	self.isDormant = true
	self.lastTimePlayed = os.time()

  self.playerTimer = hs.timer.doEvery(0.5, function()
		if obj.playerApp ~= nil and obj.playerApp:isRunning() then
			if (os.time() - obj.lastTimePlayed) > 5 * 60 then
				obj.isDormant = true
			else
				obj.isDormant = false
			end
      obj:setPlayerMenus()
			if getCurrentPlayerState() == 'playing' then
				obj.lastTimePlayed = os.time()
      end
    end
	end):start()

	self.currentSong = ''
  self.currentSongDuration = 0
	self.currentSongPosition = 0

  self.watcher = hs.application.watcher.new(function(name, event, app)
    if name == self.playerName then
      if event == 2 or event == hs.application.watcher.terminated then
        obj.playerTimer:stop()
        obj:unloadPlayerMenus()
        obj.playerMenu:setIcon(self.icon, true)
      elseif event == 1 or event == hs.application.watcher.launched then
        obj.playerTimer:start()
      end
    end
	end):start()

end

return obj
