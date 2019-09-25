--- === SDC Music ===
local obj = {}
obj.__index = obj
obj.name = "SDCMusic"

function script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  return str:match("(.*/)")
end

local iconSize = 14.0
local icon = hs.image.imageFromPath(script_path() .. 'images/music_red.pdf'):setSize({ w = iconSize, h = iconSize })
local iconPlay = hs.image.imageFromPath(script_path() .. 'images/play.pdf'):setSize({ w = iconSize, h = iconSize })
local iconPause = hs.image.imageFromPath(script_path() .. 'images/pause.pdf'):setSize({ w = iconSize, h = iconSize })

function songString(artist, track)
  return artist .. ' - ' .. '"' .. track .. '"'
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function getMusicState()
	asBool, asObject, asDesc = hs.applescript([[
		tell application "Music"
			return "" & player state
		end tell
	]])
	return asObject
end

function musicPlayPause()
	hs.applescript('tell application "Music" to playpause')
end

function musicCurrentTrack()
	ok, artist = hs.applescript([[
		tell application "Music"
			get artist of current track
		end tell
	]])
	ok, album = hs.applescript([[
		tell application "Music"
			get album of current track
		end tell
	]])
	ok, name = hs.applescript([[
		tell application "Music"
			get name of current track
		end tell
	]])
	ok, duration = hs.applescript([[
		tell application "Music"
			get duration of current track
		end tell
	]])
	ok, playerPosition = hs.applescript([[
		tell application "Music"
			return player position
		end tell
	]])
	return {
		artist = artist,
		album = album,
		name = name,
		duration = duration,
		playerPosition = playerPosition
	}
end

function obj:setPlayerMenus()
	currentState = getMusicState()
  if obj.playerControlMenu then
    if currentState == 'playing' then
      obj.playerControlMenu:setIcon(iconPause)
    else
      obj.playerControlMenu:setIcon(iconPlay)
    end
	end

	currentTrack = musicCurrentTrack()
	if obj.playerTitleMenu and currentTrack.artist and currentTrack.name then

		newSongString = songString(currentTrack.artist, currentTrack.name)
    obj.currentSongPosition = currentTrack.playerPosition

    if newSongString ~= obj.currentSong then
      obj.currentSongDuration = currentTrack.duration

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
          local notification = hs.notify.new({ title = currentTrack.name, subTitle = 'Artist: ' .. currentTrack.artist, informativeText = 'Album: ' .. currentTrack.album })
          notification:setIdImage(hs.image.imageFromAppBundle('com.apple.Music'))
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
        barWidth = titleWidth + 1 * fontCharacterWidth
			end

			textColor = '000000'

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
					fillColor = { ['hex'] = 'f46060' }
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
  musicPlayPause()
  obj:setPlayerMenus()
end

function obj:togglePlayer()
  playerApp = hs.application.find('Music')
  if hs.application.find('Music'):isRunning() and playerApp:isFrontmost() then
    playerApp:hide()
  else
    hs.application.launchOrFocus('Music')
  end
end

function obj:init()

  self.computerName = hs.host.localizedName()
  self.screenClass = 'large' -- assumes large iMac
  if string.match(string.lower(self.computerName), 'macbook') then
    self.screenClass = 'small'
  end

  self.showCurrentSongProgressBar = true
  self.showNotifications = true
  self.showAlerts = false

  self.playerTitleMenu = hs.menubar.new():setClickCallback(obj.togglePlayer)
  self.playerControlMenu = hs.menubar.new():setClickCallback(obj.playerTogglePlayPause)

  self.playerMenu = hs.menubar.new()
    :setClickCallback(obj.togglePlayer)
    :setIcon(icon, true)

  self.playerTimer = hs.timer.doEvery(0.5, function()
    if hs.application.find('Music'):isRunning() then
      obj:setPlayerMenus()
      if getMusicState() == 'playing' then
        obj.playerMenu:setIcon(icon, false)
      else
        obj.playerMenu:setIcon(icon, true)
      end
    end
	end):start()

	self.currentSong = ''
  self.currentSongDuration = 0
  self.currentSongPosition = 0

  self.watcher = hs.application.watcher.new(function(name, event, app)
    if name == 'Music' then
      if event == 2 or event == hs.application.watcher.terminated then
        obj.playerTimer:stop()
        obj:unloadPlayerMenus()
        obj.playerMenu:setIcon(icon, true)
      elseif event == 1 or event == hs.application.watcher.launched then
        obj.playerTimer:start()
      end
    end
	end):start()

end

return obj
