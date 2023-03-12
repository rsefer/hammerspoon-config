--- === SDC Overcast ===
local obj = {}
obj.__index = obj
obj.name = "SDCOvercast"

local overcastWebviewHome = 'https://overcast.fm/podcasts'
local viewWidth = 375
local viewHeight = 335

function trackString(artist, track)
	track = track:gsub(artist, '')
	track = track:gsub(' | ', '')
  return artist .. ' - ' .. '"' .. track .. '"'
end

function obj:setPlayerMenus()
	if obj.player.isDormant == true then
		obj.overcastWebview:url(overcastWebviewHome)
		obj.menus.controlMenu:setIcon(nil)
		obj.menus.titleMenu:setIcon(nil)
		obj.currentTrack.albumArt = nil
		do return end
	end
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
		if obj.player.isPlaying then
			obj.player.lastTimePlayed = os.time()
		end
		obj.player.isDormant = (os.time() - obj.player.lastTimePlayed) > 5 * 60
		obj:setPlayerMenus()
	end, 4)
end

function obj:togglePlayPause()
  obj.overcastWebview:evaluateJavaScript('togglePlayPause();')
end

function obj:toggleWebview()
  if obj.isShown then
    obj.overcastWebview:hide()
    obj.isShown = false
  else
    obj.overcastWebview:show():bringToFront(true)
		obj.overcastWebview:hswindow():moveToScreen(hs.screen.primaryScreen()):focus()
    obj.isShown = true
  end
end

function obj:playerRewind()
	obj.overcastWebview:evaluateJavaScript('rewind();')
end

function obj:playerFastForward()
	obj.overcastWebview:evaluateJavaScript('fastForward();')
end

function obj:bindHotkeys(mapping)
  hs.spoons.bindHotkeysToSpec({
		playerRewind = hs.fnutils.partial(self.playerRewind, self),
		playerFastForward = hs.fnutils.partial(self.playerFastForward, self)
  }, mapping)
end

function obj:init()

  self.isShown = false
  self.showProgressBar = true
  self.hideSpotify = true
  self.hideItunes = true

  self.overcastToolbar = hs.webview.toolbar.new('myConsole', { { id = 'resetBrowser', label = 'Home', fn = function(t, w, i) self.overcastWebview:url(overcastWebviewHome) end } })
    :sizeMode('small')
    :displayMode('label')

	self.player = {
		name = 'Overcast',
		icon = hs.image.imageFromPath(hs.spoons.scriptPath() .. 'images/overcast_orange.pdf'):setSize({ w = hs.settings.get('menuIconSize'), h = hs.settings.get('menuIconSize') }),
		color = 'fc7e0f'
	}

	self.player.lastState = nil
	self.player.isDormant = false
	self.player.lastTimePlayed = os.time()

	self.menus = {
		titleMenu = hs.menubar.new():autosaveName('Overcast Title'):setClickCallback(obj.toggleWebview),
		controlMenu = hs.menubar.new():autosaveName('Overcast Control'):setClickCallback(obj.togglePlayPause),
		playerMenu = hs.menubar.new():autosaveName('Overcast Player'):setClickCallback(obj.toggleWebview):setIcon(self.player.icon, true)
	}

	self.currentTrack = {}
	self.timer = nil

  self.overcastMenuFrame = self.menus.playerMenu:frame()
  self.rect = hs.geometry.rect((self.overcastMenuFrame.x + self.overcastMenuFrame.w / 2) - (viewWidth / 2), self.overcastMenuFrame.y, viewWidth, viewHeight)

  self.overcastJS = hs.webview.usercontent.new('idhsovercastwebview')

  local injectFileResult = ''
  for line in io.lines(hs.spoons.scriptPath() .. "inject.js") do injectFileResult = injectFileResult .. line end

  localjsScript = "var thome = '" .. overcastWebviewHome .. "';" .. injectFileResult
  self.overcastJS:injectScript({ source = localjsScript, mainFrame = true, injectionTime = 'documentEnd' })
    :setCallback(function(message)

			obj:playerCheck()

      if message.body.page == 'home' or message.body.progress >= 1 then
        obj.menus.titleMenu:setIcon(nil)
        obj.menus.controlMenu:setIcon(nil)
        obj.menus.playerMenu:setIcon(obj.player.icon, false)
        if message.body.podcast ~= nil then
          local notification = hs.notify.new({ title = 'Overcast', subTitle = 'Finished playing ' .. message.body.podcast.name })
          notification:setIdImage(iconFull)
          notification:send()
          hs.timer.doAfter(2.5, function() notification:withdraw() end)
        end
        if message.body.isFinished or (message.body.progress ~=nil and message.body.progress >= 1) then
          self.overcastWebview:url(overcastWebviewHome)
        end
      elseif message.body.hasPlayer and message.body.hasPlayer == true then

				obj.currentTrack = {
					artist = message.body.podcast.name,
					name = message.body.podcast.episodeTitle,
					duration = message.body.duration,
					position = message.body.position
				}

        if message.body.isPlaying == true then

					obj.player.isPlaying = true
					obj.player.isDormant = false

					obj.menus.playerMenu:setIcon(obj.player.icon, false)
          obj.menus.controlMenu:setIcon(iconPause, true)

          -- if obj.hideSpotify then
          --   if hs.spotify.isPlaying() then
          --     hs.spotify.pause()
          --   end
          -- end

          if obj.hideItunes then
            if hs.itunes.isPlaying() then
              hs.itunes.pause()
            end
          end

        else
					obj.player.isPlaying = false
          obj.menus.controlMenu:setIcon(iconPlay, true)
        end

				if obj.currentTrack.artist and obj.currentTrack.name then

					workingArtist = obj.currentTrack.artist
					newTrackString = trackString(workingArtist, obj.currentTrack.name)

					currentTrackPositionPercentage = message.body.progress

					timeCharacters = 0

					timeString = ''
					hasTrackInfo = true

					minutesRemaining = math.ceil((obj.currentTrack.duration - obj.currentTrack.position) / 60)
					timeString = ' [' .. minutesToClock(minutesRemaining, false, false) .. ']'
					timeCharacters = timeCharacters + string.len(timeString)
					newTrackString = newTrackString .. timeString

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
					maxWidth = 150
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

    end)

  self.overcastWebview = hs.webview.newBrowser(self.rect, { developerExtrasEnabled = true }, self.overcastJS)
    :url(overcastWebviewHome)
    :allowTextEntry(true)
    :shadow(true)
    :attachedToolbar(self.overcastToolbar)
		:windowCallback(function(action, webview, state)
			if action == 'focusChange' and state ~= true then
				self.overcastWebview:hide()
		    self.isShown = false
			end
		end)

end

return obj
