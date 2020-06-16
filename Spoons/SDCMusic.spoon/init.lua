--- === SDC Music ===
local obj = {}
obj.__index = obj
obj.name = "SDCMusic"

function songString(artist, track)
	track = track:gsub(artist, '')
	track = track:gsub(' | ', '')
  return artist .. ' - ' .. '"' .. track .. '"'
end

function getCurrentPlayerState()
	playbackState = obj.playerModule:getPlaybackState()
	workingStateString = 'paused'
	if playbackState == obj.playerModule.state_paused then
		workingStateString = 'paused'
	elseif playbackState == obj.playerModule.state_playing then
		workingStateString = 'playing'
	elseif playbackState == obj.playerModule.state_stopped then
		workingStateString = 'stopped'
	end
	return workingStateString
end

function getCurrentTrackInfo()
	if obj.playerModule:getCurrentTrack() then
		return {
			artist = obj.playerModule:getCurrentArtist(),
			album = obj.playerModule:getCurrentAlbum(),
			name = obj.playerModule:getCurrentTrack(),
			duration = obj.playerModule:getDuration(),
			playerPosition = obj.playerModule:getPosition()
		}
	end
	return {}
end

function obj:spotifyGetCode(code)

	if not settingExists('spotify_client_id') then
		setupSetting('spotify_client_id', 'Spotify Client ID')
	end
	if not settingExists('spotify_client_secret') then
		setupSetting('spotify_client_secret', 'Spotify Client Secret')
	end

	if not code then
		hs.urlevent.openURL('https://accounts.spotify.com/authorize?client_id=' .. hs.settings.get('spotify_client_id') .. '&response_type=code&redirect_uri=https://rsefer.com/&scope=user-read-private%20user-read-playback-state%20streaming%20app-remote-control&state=rsefer')
		newCode = setupSetting('spotify_authorization_code', 'Spotify Authorization Code', '', true)
		if newCode ~= nil then
			return obj:spotifyGetCode(newCode)
		end
	end

	getTokenStatus, getTokenBody, getTokenHeaders = hs.http.post('https://accounts.spotify.com/api/token', 'client_id=' .. hs.settings.get('spotify_client_id') .. '&client_secret=' .. hs.settings.get('spotify_client_secret') .. '&grant_type=authorization_code&code=' .. code .. '&redirect_uri=https://rsefer.com/')
	decodedGetTokenBody = hs.json.decode(getTokenBody)

	if getTokenStatus == 400 then
		return obj:spotifyGetCode()
	elseif decodedGetTokenBody['access_token'] ~= nil and decodedGetTokenBody['refresh_token'] ~= nil then
		hs.settings.set('spotify_access_token', decodedGetTokenBody['access_token'])
		hs.settings.set('spotify_refresh_token', decodedGetTokenBody['refresh_token'])
	end

	return decodedGetTokenBody
end

function obj:spotifyGetAccessToken(refreshToken)
	if not refreshToken then
		return hs.alert('Could not obtain access token.')
	end

	getTokenStatus, getTokenBody, getTokenHeaders = hs.http.post('https://accounts.spotify.com/api/token', 'client_id=' .. hs.settings.get('spotify_client_id') .. '&client_secret=' .. hs.settings.get('spotify_client_secret') .. '&grant_type=refresh_token&refresh_token=' .. refreshToken)
	decodedGetTokenBody = hs.json.decode(getTokenBody)

	if getTokenStatus == 400 then
		return obj:spotifyGetCode()
	elseif decodedGetTokenBody['access_token'] ~= nil then
		hs.settings.set('spotify_access_token', decodedGetTokenBody['access_token'])
		if decodedGetTokenBody['refresh_token'] ~= nil then
			hs.settings.set('spotify_refresh_token', decodedGetTokenBody['refresh_token'])
		end
	end

	return decodedGetTokenBody
end

function obj:spotifySwitchPlayer()
	obj:spotifyGetAccessToken(hs.settings.get('spotify_refresh_token'))

	devicesHeaders = {}
	devicesHeaders['Authorization'] = 'Bearer ' .. hs.settings.get('spotify_access_token')
	devicesStatus, devicesBody, devicesReturnHeaders = hs.http.get('https://api.spotify.com/v1/me/player/devices', devicesHeaders)

	if devicesStatus ~= 200 then
		obj:spotifyGetAccessToken(hs.settings.get('spotify_refresh_token'))
		hs.alert('Had to get new token. Try again.')
		return
	end

	decodedDevicesBody = hs.json.decode(devicesBody)

	if decodedDevicesBody['devices'] ~= nil then
		allDevices = {}
		for x, device in ipairs(decodedDevicesBody['devices']) do
			if device['type'] == 'Computer' then table.insert(allDevices, device) end
		end
		for x, device in ipairs(decodedDevicesBody['devices']) do
			if device['type'] == 'Speaker' then table.insert(allDevices, device) end
		end
		for x, device in ipairs(decodedDevicesBody['devices']) do
			if device['type'] ~= 'Computer' and device['type'] ~= 'Speaker' then table.insert(allDevices, device) end
		end

		finalDevices = {}
		everywhereDevice = nil
		for x, device in ipairs(allDevices) do
			if device['name'] ~= nil then
				if string.match(string.lower(device['name']), 'mac') then
					device['name'] = '💻 ' .. device['name']
				elseif string.match(string.lower(device['name']), 'phone') then
					device['name'] = '📱 ' .. device['name']
				elseif string.match(string.lower(device['name']), 'pad') then
					device['name'] = '⌨️ ' .. device['name']
				elseif string.match(string.lower(device['name']), 'bed') then
					device['name'] = '🛏 ' .. device['name']
				elseif string.match(string.lower(device['name']), 'dining') then
					device['name'] = '🍛 ' .. device['name']
				elseif string.match(string.lower(device['name']), 'bath') then
					device['name'] = '🚽 ' .. device['name']
				elseif string.match(string.lower(device['name']), 'appletv') then
					device['name'] = '📺 ' .. device['name']
				elseif string.match(string.lower(device['name']), 'everywhere') then
					device['name'] = '🌎 ' .. device['name']
				end
				if device['is_active'] then
					device['name'] = '→ ' .. device['name']
				end
				deviceTable = {
					uuid = device['id'],
					text = device['name']
				}
				if string.match(string.lower(device['name']), 'everywhere') then
					everywhereDevice = deviceTable
				else
					table.insert(finalDevices, deviceTable)
				end
			end
		end
		if everywhereDevice ~= nil then
			table.insert(finalDevices, everywhereDevice)
		end
		hs.chooser.new(function(choice)
			if choice then
				if choice.uuid ~= 0 then
					-- using cURL because hammerspoon is unable to execute PUT commands
					string = 'curl -X "PUT" "https://api.spotify.com/v1/me/player" --data "{\\\"device_ids\\\":[\\\"' .. choice.uuid .. '\\\"]}" -H "Accept: application/json" -H "Authorization: Bearer ' .. hs.settings.get('spotify_access_token') .. '"'
					hs.execute(string)
				end
			end
		end):choices(finalDevices):width(30):rows(tablelength(finalDevices)):placeholderText('Spotify Devices'):show()
	end

end

function obj:setPlayerMenus()
	if obj.isDormant == true then
		obj.playerControlMenu:setIcon(nil)
		obj.playerTitleMenu:setIcon(nil)
		do return end
	end
	currentState = getCurrentPlayerState()

	if currentState == 'playing' then
    obj.playerControlMenu:setIcon(iconPause)
	else
		obj.playerControlMenu:setIcon(iconPlay)
	end

	currentTrack = getCurrentTrackInfo()
	if currentTrack.artist and currentTrack.name then

		workingArtist = currentTrack.artist
		if not workingArtist or string.len(workingArtist) < 1 then
			workingArtist = currentTrack.album
		end
		newSongString = songString(workingArtist, currentTrack.name)
    obj.currentSongPosition = currentTrack.playerPosition

		if currentTrack.duration ~= nil then
			obj.currentSongDuration = currentTrack.duration
		else
			obj.currentSongDuration = 300
		end

		currentSongPositionPercentage = obj.currentSongPosition / obj.currentSongDuration

		timeCharacters = 0

		timeString = ''
		hasTrackInfo = true

		if obj.currentSongDuration > 15 * 60 then -- if long, show time remaining
			minutesRemaining = math.ceil((obj.currentSongDuration - obj.currentSongPosition) / 60)
			timeString = ' [' .. minutesToClock(minutesRemaining, false, false) .. ']'
			timeCharacters = timeCharacters + string.len(timeString)
			newSongString = newSongString .. timeString
		end

		if currentTrack.artist == '' and currentTrack.name == '' then
			hasTrackInfo = false
			newSongString = '📱' .. timeString
		end

		textLineBreak = 'wordWrap'
		textSize = 12
		fontCharacterWidth = textSize * .62
		textVerticalOffset = 1
		menubarHeight = 22
		titleWidth = string.len(newSongString) * fontCharacterWidth
		maxWidth = 375
		if hs.settings.get('deskSizeClass') == 'large' then
			maxWidth = 500
		end
		if titleWidth > maxWidth then
			barWidth = maxWidth
			textLineBreak = 'truncateMiddle'
		else
			barWidth = titleWidth
		end
		barWidth = round(barWidth)

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
				textSize = textSize,
				textLineBreak = textLineBreak,
				textColor = { ['hex'] = textColor },
				textFont = 'SF Mono',
				frame = { x = '0%', y = textVerticalOffset, h = '100%', w = '100%' }
			})

		obj.playerTitleMenu:setIcon(obj.menubarCanvas:imageFromCanvas(), false)

    obj.currentSong = newSongString
  end
end

function obj:notifyTrack(currentTrack)
	workingArtist = currentTrack.artist
	if not workingArtist or string.len(workingArtist) < 1 then
		workingArtist = currentTrack.album
	end
	workingImage = hs.image.imageFromAppBundle(obj.playerApp:bundleID())

	if obj.playerName == 'Spotify' then
		asBool, asObject, asDesc = hs.osascript.applescript('tell application "Spotify" to return artwork url of the current track')
		if string.len(asObject) > 0 then
			workingImage = hs.image.imageFromURL(asObject)
		end
	elseif setupSetting('discogs_key') and setupSetting('discogs_secret') then
		discogsURL = 'https://api.discogs.com/database/search?query=' .. urlencode(currentTrack.artist .. ' - ' .. currentTrack.album) .. '&per_page=1&page=1&key=' .. hs.settings.get('discogs_key') .. '&secret=' .. hs.settings.get('discogs_secret')
		status, body, headers = hs.http.get(discogsURL)
		if status == 200 then
			json = hs.json.decode(body)
			if json.results and json.results[1] and json.results[1].thumb then
				workingImage = hs.image.imageFromURL(json.results[1].thumb)
			end
		end
	end

	hs.notify.new(function()
		hs.application.launchOrFocus(obj.playerName)
	end, {
		hasActionButton = true,
		actionButtonTitle = 'Open',
		title = currentTrack.name,
		subTitle = 'Artist: ' .. workingArtist,
		informativeText = 'Album: ' .. currentTrack.album,
		setIdImage = workingImage,
		withdrawAfter = 2.5
	}):send()
end

function obj:unloadPlayerMenus()
  obj.playerControlMenu:setIcon(nil)
  obj.playerTitleMenu:setIcon(nil)
  if obj.currentSongProgressBar then
    obj.currentSongProgressBar:delete()
  end
end

function obj:playerCheck()
	if obj.timer ~= nil then
		obj.timer:stop()
	end
	obj.timer = hs.timer.doUntil(function()
		return obj.isDormant
	end, function()
		if getCurrentPlayerState() == 'playing' then
			obj.lastTimePlayed = os.time()
		end
		obj.isDormant = (os.time() - obj.lastTimePlayed) > 5 * 60
		obj:setPlayerMenus()
	end, 4)
end

function obj:togglePlayer()
  if obj.playerApp ~= nil and obj.playerApp:isRunning() and obj.playerApp:isFrontmost() then
    obj.playerApp:hide()
  else
    hs.application.launchOrFocus(obj.playerName)
  end
end

function obj:bindHotkeys(mapping)
  hs.spoons.bindHotkeysToSpec({
		spotifySwitchPlayer = hs.fnutils.partial(self.spotifySwitchPlayer, self)
  }, mapping)
end

function obj:init()

	self.playerName = hs.settings.get('musicPlayerName')
	self.playerApp = hs.application.get(self.playerName)
	if self.playerName == 'Spotify' then
		self.playerModule = hs.spotify
	else
		self.playerModule = hs.itunes
	end
  self.showNotifications = true

	self.icon = hs.image.imageFromAppBundle('com.apple.Music'):setSize({ w = hs.settings.get('menuIconSize'), h = hs.settings.get('menuIconSize') })
	self.distributedPlaybackChangedString = 'com.apple.Music.playerInfo'
	if self.playerName == 'Spotify' then
		self.icon = hs.image.imageFromAppBundle('com.spotify.client'):setSize({ w = hs.settings.get('menuIconSize'), h = hs.settings.get('menuIconSize') })
		self.distributedPlaybackChangedString = 'com.spotify.client.PlaybackStateChanged'
	end

  self.playerTitleMenu = hs.menubar.new():setClickCallback(obj.togglePlayer)
  self.playerControlMenu = hs.menubar.new():setClickCallback(obj.playerModule.playpause())

  self.playerMenu = hs.menubar.new()
    :setClickCallback(obj.togglePlayer)
		:setIcon(self.icon, false)

	self.isDormant = false
	self.lastTimePlayed = os.time()
	self.lastState = nil
	self.timer = nil

	self.currentSong = ''
  self.currentSongDuration = 0
	self.currentSongPosition = 0

  self.watcher = hs.application.watcher.new(function(name, event, app)
    if name == self.playerName then
      if event == 2 or event == hs.application.watcher.terminated then
        obj:unloadPlayerMenus()
        obj.playerMenu:setIcon(self.icon, false)
      end
    end
	end)

	self.distributednotifications = hs.distributednotifications.new(function(name, object, userInfo)
		if userInfo['Player State'] == 'Playing' then
			obj.isDormant = false
			if obj.lastState ~= 'Paused' then
				obj:notifyTrack(getCurrentTrackInfo())
			end
			obj.lastTimePlayed = os.time()
			obj:playerCheck()
		end
		obj.lastState = userInfo['Player State']
		obj:setPlayerMenus()
	end, self.distributedPlaybackChangedString)

end

function obj:start()

	self.watcher:start()
	self.distributednotifications:start()

	if getCurrentPlayerState() == 'playing' then
		self:playerCheck()
	end

end

function obj:stop()

	self.watcher:stop()
	self.distributednotifications:stop()
	if self.timer ~= nil then
		self.timer:stop()
	end

end

return obj
