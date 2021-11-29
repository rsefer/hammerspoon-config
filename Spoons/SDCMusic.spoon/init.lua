--- === SDC Music ===
local obj = {}
obj.__index = obj
obj.name = "SDCMusic"

local trackNotification

function trackString(artist, track)
	track = track:gsub(artist, '')
	track = track:gsub(' | ', '')
  return artist .. ' - ' .. '"' .. track .. '"'
end

function obj:getCurrentPlayerState()
	playbackState = obj.player.module:getPlaybackState()
	workingStateString = 'paused'
	if playbackState == obj.player.module.state_paused then
		workingStateString = 'paused'
	elseif playbackState == obj.player.module.state_playing then
		workingStateString = 'playing'
	elseif playbackState == obj.player.module.state_stopped then
		workingStateString = 'stopped'
	end
	return workingStateString
end

function obj:updateCurrentTrackInfo()
	if obj.player.module:getCurrentTrack() then
		obj.currentTrack = {
			artist = obj.player.module:getCurrentArtist() or '',
			album = obj.player.module:getCurrentAlbum() or '',
			name = obj.player.module:getCurrentTrack() or '',
			duration = obj.player.module:getDuration() or 300,
			position = obj.player.module:getPosition() or 0,
			albumArt = obj.currentTrack.albumArt or ''
		}
	else
		obj.currentTrack = {}
	end
end

function obj:spotifyGetCode(code)

	if not settingExists('spotify_client_id') then
		setupSetting('spotify_client_id', 'Spotify Client ID')
	end
	if not settingExists('spotify_client_secret') then
		setupSetting('spotify_client_secret', 'Spotify Client Secret')
	end

	if not code then
		hs.urlevent.openURL('https://accounts.spotify.com/authorize?client_id=' .. hs.settings.get('spotify_client_id') .. '&response_type=code&redirect_uri=https://rsefer.com/&scope=user-library-read%20user-read-private%20user-read-playback-state%20user-read-playback-position%20streaming%20app-remote-control%20streaming&state=rsefer')
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

function obj:getSpotifyPodcastEpisodes()
	obj:spotifyGetAccessToken(hs.settings.get('spotify_refresh_token'))

	hs.settings.set('spotify_podcasts_episode_date', os.time())

	showsHeaders = {}
	showsHeaders['Authorization'] = 'Bearer ' .. hs.settings.get('spotify_access_token')
	showsStatus, showsBody, showsReturnHeaders = hs.http.get('https://api.spotify.com/v1/me/shows', showsHeaders)

	if showsStatus ~= 200 then
		obj:spotifyGetAccessToken(hs.settings.get('spotify_refresh_token'))
		hs.alert('Had to get new token. Try again.')
		return
	end
	decodedShowsBody = hs.json.decode(showsBody)
	episodes = {}
	for x, show in ipairs(decodedShowsBody['items']) do
		showHeaders = {}
		showHeaders['Authorization'] = 'Bearer ' .. hs.settings.get('spotify_access_token')
		showStatus, showBody, showReturnHeaders = hs.http.get('https://api.spotify.com/v1/shows/' .. show['show']['id'] .. '/episodes?limit=2', showHeaders)
		decodedShowBody = hs.json.decode(showBody)
		workingImage = nil
		if show['show']['images'][3] ~= nil then
			workingImage = show['show']['images'][3]['url']
		end
		for x, episode in ipairs(decodedShowBody['items']) do
			episodeObject = {
				id = episode['id'],
				episodeName = episode['name'],
				showName = show['show']['name'],
				imageURL = workingImage,
				release_date = episode['release_date'],
				release_date_full = os.time({ year = string.sub(episode['release_date'], 1, 4), month = string.sub(episode['release_date'], 6, 7), day = string.sub(episode['release_date'], 9, 10), hour = 12 }),
				uri = episode['uri'],
				resume_point = episode['resume_point'],
				duration_ms = episode['duration_ms']
			}
			table.insert(episodes, episodeObject)
		end
	end
	hs.settings.set('spotify_podcast_episodes', episodes)
end

function obj:transformEpisodesList()
	tmpEpisodes = hs.settings.get('spotify_podcast_episodes')
	tmpTableWithDates = {}
	for x, episode in ipairs(tmpEpisodes) do
		tmpEpisode = episode
		workingText = '[' .. tmpEpisode['release_date'] .. '] - '
		tmpEpisode['is_fully_played'] = false
		if tmpEpisode['resume_point'] ~= nil then
			if tmpEpisode['resume_point']['fully_played'] ~= nil and tmpEpisode['resume_point']['fully_played'] == true then
				workingText = '✓ ' .. workingText
				tmpEpisode['is_fully_played'] = true
			elseif tmpEpisode['resume_point']['resume_position_ms'] ~= nil and tmpEpisode['resume_point']['resume_position_ms'] > 0 then
				remainingText = ''
				if tmpEpisode['duration_ms'] ~= nil then
					remainingText = ' ' .. minutesToClock((tmpEpisode['duration_ms'] - tmpEpisode['resume_point']['resume_position_ms']) / 1000 / 60) .. ' left'
				end
				workingText = utf8.char(0x100002) .. remainingText .. ' ' .. workingText
			end
		end
		workingText = workingText .. tmpEpisode['episodeName']
		styleObj = {
			color = { hex = '#ffffff', alpha = 1 }
		}
		if tmpEpisode['is_fully_played'] then
			styleObj['color']['alpha'] = 0.25
		end
		tmpEpisode['uuid'] = tmpEpisode['id']
		tmpEpisode['text'] = hs.styledtext.new(workingText, styleObj)
		tmpEpisode['subText'] = hs.styledtext.new(tmpEpisode['showName'], styleObj)
		if episode['imageURL'] ~= nil then
			tmpEpisode['image'] = hs.image.imageFromURL(episode['imageURL'])
		end
		if not tmpEpisode['is_fully_played'] or os.time() - tmpEpisode['release_date_full'] < 60 * 60 * 24 * 7 then
			if not tmpTableWithDates[tmpEpisode['release_date']] then
				tmpTableWithDates[tmpEpisode['release_date']] = {}
			end
			table.insert(tmpTableWithDates[tmpEpisode['release_date']], tmpEpisode)
		end
	end
	local tkeys = {}
	for date, episodes in pairs(tmpTableWithDates) do
		table.insert(tkeys, date)
		table.sort(episodes, function(a, b)
			return b.is_fully_played and not a.is_fully_played
		end)
	end
	table.sort(tkeys, function(a, b) return b < a end)
	tmpTable = {}
	for x, key in pairs(tkeys) do
		for i, episode in pairs(tmpTableWithDates[key]) do
			table.insert(tmpTable, episode)
		end
	end
	obj.episodesList = tmpTable
	return obj.episodesList
end

function obj:setEpisodeChooserToolbar()
	if obj.episodeChooserToolbar ~= nil then
		obj.episodeChooserToolbar:delete()
	end
	timestamp = os.date('%I:%M%p', hs.settings.get('spotify_podcasts_episode_date'))
	if string.sub(timestamp, 1, 1) == '0' then
		timestamp = string.sub(timestamp, 2)
	end
	timestamp = os.date('%A @ ', hs.settings.get('spotify_podcasts_episode_date')) .. timestamp
	obj.episodeChooserToolbar = hs.webview.toolbar.new('episodeChooserToolbar', {
		{
			id = 'episodesRefreshedLast',
			label = 'Last Updated: ' .. timestamp,
			selectable = false,
			fn = function()
				--
			end
		},
		{
			id = 'episodesRefresh',
			label = 'Refresh',
			selectable = true,
			fn = function()
				obj:setEpisodeChooserToolbar()
				obj:getSpotifyPodcastEpisodes()
			end
		}
	}):sizeMode('small'):displayMode('label')
	obj.episodeChooser:attachedToolbar(obj.episodeChooserToolbar)
end

function obj:spotifyPlayPodcastEpisode()
	obj.episodeChooser:choices(obj.episodesList):show()
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
				if device['name'] == '4ed03509-ef37-4dab-a6a8-c38dc6546aeb' then -- fixes reporting issue
					device['name'] = 'Bedroom Echo Dot'
				end
				if string.match(string.lower(device['name']), 'mac') then
					device['image'] = textToImage('💻')
				elseif string.match(string.lower(device['name']), 'phone') then
					device['image'] = textToImage('📱')
				elseif string.match(string.lower(device['name']), 'pad') then
					device['image'] = textToImage('⌨️')
				elseif string.match(string.lower(device['name']), 'bed') then
					device['image'] = textToImage('🛏')
				elseif string.match(string.lower(device['name']), 'dining') or string.match(string.lower(device['name']), 'kitchen') then
					device['image'] = textToImage('🍛')
				elseif string.match(string.lower(device['name']), 'bath') then
					device['image'] = textToImage('🚽')
				elseif string.match(string.lower(device['name']), 'appletv') then
					device['image'] = textToImage('📺')
				elseif string.match(string.lower(device['name']), 'everywhere') then
					device['image'] = textToImage('🌎')
				end
				if device['is_active'] then
					device['subText'] = 'Currently Playing'
				else
					device['subText'] = nil
				end
				deviceTable = {
					uuid = device['id'],
					text = device['name'],
					subText = device['subText']
				}
				if device['image'] then
					deviceTable['image'] = device['image']
				end
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
			if not choice then return end
			if choice.uuid ~= 0 then
				-- using cURL because hammerspoon is unable to execute PUT commands
				string = 'curl -X "PUT" "https://api.spotify.com/v1/me/player" --data "{\\\"device_ids\\\":[\\\"' .. choice.uuid .. '\\\"]}" -H "Accept: application/json" -H "Authorization: Bearer ' .. hs.settings.get('spotify_access_token') .. '"'
				hs.execute(string)
			end
		end):choices(finalDevices):width(30):rows(tablelength(finalDevices) - 1):placeholderText('Spotify Devices'):show()
	end

end

function obj:setPlayerMenus()
	obj:updateCurrentTrackInfo()
	if obj.player.isDormant == true then
		obj.menus.controlMenu:setIcon(nil)
		obj.menus.titleMenu:setIcon(nil)
		obj.currentTrack.albumArt = nil
		do return end
	end
	currentState = obj:getCurrentPlayerState()

	if currentState == 'playing' then
    obj.menus.controlMenu:setIcon(iconPause, true)
	else
		obj.menus.controlMenu:setIcon(iconPlay, true)
	end

	if obj.currentTrack.artist and obj.currentTrack.name then

		workingArtist = obj.currentTrack.artist
		if not workingArtist or string.len(workingArtist) < 1 then
			workingArtist = obj.currentTrack.album
		end
		newTrackString = trackString(workingArtist, obj.currentTrack.name)

		currentTrackPositionPercentage = obj.currentTrack.position / obj.currentTrack.duration

		timeCharacters = 0

		timeString = ''
		hasTrackInfo = true

		if obj.currentTrack.duration > 15 * 60 then -- if long, show time remaining
			minutesRemaining = math.ceil((obj.currentTrack.duration - obj.currentTrack.position) / 60)
			timeString = ' [' .. minutesToClock(minutesRemaining, false, false) .. ']'
			timeCharacters = timeCharacters + string.len(timeString)
			newTrackString = newTrackString .. timeString
		end

		if obj.currentTrack.artist == '' and obj.currentTrack.name == '' then
			hasTrackInfo = false
			newTrackString = '📱' .. timeString
		end

		textLineBreak = 'wordWrap'
		textSize = 12
		fontCharacterWidth = textSize * .62
		textVerticalOffset = 1
		menubarHeight = 22
		titleWidth = string.len(newTrackString) * fontCharacterWidth
		maxWidth = 100
		if hs.settings.get('deskSizeClass') == 'large' then
			maxWidth = 400
		end
		if titleWidth > maxWidth then
			barWidth = maxWidth
			textLineBreak = 'truncateMiddle'
		else
			barWidth = titleWidth
		end
		barWidth = round(barWidth)

		textColor = '000000'

		if hs.host.interfaceStyle() == 'Dark' then
			textColor = 'ffffff'
		end

		obj.menubarCanvas = hs.canvas.new({ x = 0, y = 0, h = menubarHeight, w = barWidth })
			:appendElements({
				id = 'trackProgress',
				type = 'rectangle',
				action = 'fill',
				frame = {
					x = '0%',
					y = menubarHeight - 2,
					h = 2,
					w = round(currentTrackPositionPercentage * 100, 2) .. '%'
				},
				fillColor = { ['hex'] = obj.player.color }
			},
			{
				id = 'trackText',
				type = 'text',
				text = newTrackString:gsub(' ', ' '), -- replace 'normal space' character with 'en space'
				textSize = textSize,
				textLineBreak = textLineBreak,
				textColor = { ['hex'] = textColor },
				textFont = 'SF Mono',
				frame = { x = '0%', y = textVerticalOffset, h = '100%', w = '100%' }
			})

		obj.menus.titleMenu:setIcon(obj.menubarCanvas:imageFromCanvas(), false)
  end
end

function obj:getTrackAlbumArt()
	workingImage = hs.image.imageFromAppBundle(obj.player.app:bundleID())
	if obj.player.name == 'Spotify' then
		asBool, asObject, asDesc = hs.osascript.applescript('tell application "Spotify" to return artwork url of the current track')
		if asObject and string.len(asObject) > 0 then
			workingImage = hs.image.imageFromURL(asObject)
		end
	elseif setupSetting('discogs_key') and setupSetting('discogs_secret') then
		discogsURL = 'https://api.discogs.com/database/search?query=' .. urlencode(obj.currentTrack.artist .. ' - ' .. obj.currentTrack.album) .. '&per_page=1&page=1&key=' .. hs.settings.get('discogs_key') .. '&secret=' .. hs.settings.get('discogs_secret')
		status, body, headers = hs.http.get(discogsURL)
		if status == 200 then
			json = hs.json.decode(body)
			if json.results and json.results[1] and json.results[1].thumb then
				workingImage = hs.image.imageFromURL(json.results[1].thumb)
			end
		end
	end
	obj.currentTrack.albumArt = workingImage
end

function obj:notifyTrack()
	workingArtist = obj.currentTrack.artist or ''
	if not workingArtist or string.len(workingArtist) < 1 then
		workingArtist = obj.currentTrack.album or ''
	end

	if not obj.currentTrack then return end

	if trackNotification then
		trackNotification:withdraw()
	end

	trackNotification = hs.notify.new(function()
		hs.application.launchOrFocus(obj.player.name)
	end, {
		hasActionButton = true,
		actionButtonTitle = 'Open',
		title = 'Track: ' .. obj.currentTrack.name,
		subTitle = 'Artist: ' .. workingArtist,
		informativeText = 'Album: ' .. obj.currentTrack.album,
		setIdImage = obj.currentTrack.albumArt,
		contentImage = obj.currentTrack.albumArt,
		withdrawAfter = 2.5
	}):send()
end

function obj:toggleNowPlaying()
	hs.osascript.applescript('tell application "System Events" to tell process "ControlCenter" to tell menu bar 1 to click (menu bar item "Now Playing")')
end

function obj:unloadPlayerMenus()
  obj.menus.controlMenu:setIcon(nil)
  obj.menus.titleMenu:setIcon(nil)
end

function obj:playerCheck()
	if obj.timer ~= nil then
		obj.timer:stop()
	end
	obj.timer = hs.timer.doUntil(function()
		return obj.player.isDormant
	end, function()
		if obj:getCurrentPlayerState() == 'playing' then
			obj.player.lastTimePlayed = os.time()
		end
		obj.player.isDormant = (os.time() - obj.player.lastTimePlayed) > 5 * 60
		obj:setPlayerMenus()
	end, 4)
end

function obj:togglePlayer()
  if obj.player.app ~= nil and obj.player.app:isRunning() and obj.player.app:isFrontmost() then
    obj.player.app:hide()
  else
    hs.application.launchOrFocus(obj.player.name)
  end
end

function obj:playerRewind()
	obj.player.module.rw()
end

function obj:playerFastForward()
	obj.player.module.ff()
end

function obj:bindHotkeys(mapping)
  hs.spoons.bindHotkeysToSpec({
		spotifySwitchPlayer = hs.fnutils.partial(self.spotifySwitchPlayer, self),
		spotifyPlayPodcastEpisode = hs.fnutils.partial(self.spotifyPlayPodcastEpisode, self),
		playerRewind = hs.fnutils.partial(self.playerRewind, self),
		playerFastForward = hs.fnutils.partial(self.playerFastForward, self)
  }, mapping)
end

function obj:init()

	if hs.settings.get('musicPlayerName') == 'Spotify' then
		self.player = {
			name = 'Spotify',
			app = hs.application.get('Spotify'),
			module = hs.spotify,
			icon = hs.image.imageFromAppBundle('com.spotify.client'):setSize({ w = hs.settings.get('menuIconSize'), h = hs.settings.get('menuIconSize') }),
			distributedPlaybackChangedString = 'com.spotify.client.PlaybackStateChanged',
			color = '1db954'
		}
	else
		self.player = {
			name = 'Music',
			app = hs.application.get('Music'),
			module = hs.itunes,
			icon = hs.image.imageFromAppBundle('com.apple.Music'):setSize({ w = hs.settings.get('menuIconSize'), h = hs.settings.get('menuIconSize') }),
			distributedPlaybackChangedString = 'com.apple.Music.playerInfo',
			color = 'f46060'
		}
	end

	self.player.lastState = nil
	self.player.isDormant = false
	self.player.lastTimePlayed = os.time()

	self.menus = {
		titleMenu = hs.menubar.new():setClickCallback(obj.toggleNowPlaying),
		controlMenu = hs.menubar.new():setClickCallback(obj.player.module.playpause),
		playerMenu = hs.menubar.new():setClickCallback(obj.togglePlayer):setIcon(self.player.icon, false)
	}

	self.currentTrack = {}
	self.timer = nil
	self.episodesUpdateTimer = hs.timer.doEvery(15 * 60, function()
		if not hs.settings.get('spotify_podcasts_episode_date') or (os.date('*t').hour > 6 and (60 * 60 * 1) < os.time() - hs.settings.get('spotify_podcasts_episode_date')) then
			obj:getSpotifyPodcastEpisodes()
		end
	end):stop()
	self.episodesList = self:transformEpisodesList()
	self.episodeChooserToolbar = nil
	self.episodeChooser = hs.chooser.new(function(choice)
		if not choice then return end
		hs.osascript.applescript('tell application "Spotify" to play track "' .. choice.uri .. '"')
	end):width(40)
		:placeholderText('Episodes')
		:choices(self.episodesList)

	self.episodesListWatchKey = hs.settings.watchKey('settings_spotify_podcast_episodes_watcher', 'spotify_podcast_episodes', function()
		obj:setEpisodeChooserToolbar()
		obj:transformEpisodesList()
		obj.episodeChooser:choices(obj.episodesList)
	end)

  self.watcher = hs.application.watcher.new(function(name, event, app)
    if name == self.player.name then
      if event == 2 or event == hs.application.watcher.terminated then
        obj:unloadPlayerMenus()
        obj.menus.playerMenu:setIcon(self.icon, false)
      end
    end
	end)

	self.distributednotifications = hs.distributednotifications.new(function(name, object, userInfo)
		if userInfo['Player State'] == 'Playing' then
			obj.player.isDormant = false
			obj:getTrackAlbumArt()
			if obj.player.lastState ~= 'Paused' then
				obj:updateCurrentTrackInfo()
				-- obj:toggleNowPlaying()
				-- hs.timer.doAfter(2, self.toggleNowPlaying)
				obj:notifyTrack()
			end
			obj.player.lastTimePlayed = os.time()
			obj:playerCheck()
		end
		obj.player.lastState = userInfo['Player State']
		obj:setPlayerMenus()
	end, self.player.distributedPlaybackChangedString)

end

function obj:start()

	self.watcher:start()
	self.distributednotifications:start()
	self.episodesUpdateTimer:start()
	self:setEpisodeChooserToolbar()

	if obj:getCurrentPlayerState() == 'playing' then
		obj:getTrackAlbumArt()
		self:playerCheck()
	end

end

function obj:stop()

	self.watcher:stop()
	self.episodesUpdateTimer:stop()
	self.distributednotifications:stop()
	if self.timer ~= nil then
		self.timer:stop()
	end

end

return obj
