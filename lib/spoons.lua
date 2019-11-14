hs.spoons.use('SDCWindows', {
	config = {
		windowLayout = {
			{
				apps = { 'Google Chrome', 'Safari', 'Firefox', 'Music', 'Spotify', 'Photos', 'App Store', 'Coda', 'TV', 'News', 'Podcasts', 'Postman' },
				screen = hs.screen.primaryScreen(),
				size = hs.settings.get('windowSizes').thirds.right2
			},
			{
				apps = { 'Messages', 'Slack', 'Tweetbot', 'Reminders', 'Hammerspoon', 'Home' },
				screen = hs.screen.primaryScreen(),
				size = hs.settings.get('windowSizes').thirds.leftTop
			},
			{
				apps = { 'TextEdit', 'Notes' },
				screen = hs.screen.primaryScreen(),
				size = hs.settings.get('windowSizes').thirds.leftBottom
			},
			{
				apps = { 'Photoshop', 'Illustrator', 'Sketch' },
				screen = hs.screen.primaryScreen(),
				size = hs.settings.get('windowSizes').full
			},
			{
				apps = { 'Local' },
				screen = hs.screen.primaryScreen(),
				size = hs.settings.get('windowSizes').center
			},
			{
				apps = { 'Code', 'GitHub Desktop' },
				screen = screenChooser(hs.settings.get('secondaryMonitorName'), hs.screen.primaryScreen()),
				size = hs.settings.get('windowSizes').full
			},
			{
				apps = { 'Terminal', 'Hyper' },
				screen = screenChooser(hs.settings.get('tertiaryMonitorName'), hs.screen.primaryScreen()),
				size = windowScreenSizeChooser(hs.settings.get('tertiaryMonitorName'), hs.settings.get('windowSizes').full, hs.settings.get('windowSizes').thirds.leftTop)
			}
		}
	},
	hotkeys = {
		resetWindows                    = {hs.settings.get('hotkeyCombo'), 'f18'},
		moveWindowRightScreen           = {hs.settings.get('hotkeyCombo'), 'right'},
		moveWindowLeftScreen            = {hs.settings.get('hotkeyCombo'), 'left'},
		moveWindowUpScreen              = {hs.settings.get('hotkeyCombo'), 'up'},
		moveWindowDownScreen            = {hs.settings.get('hotkeyCombo'), 'down'},
		sizeLeftHalf                    = {hs.settings.get('hotkeyCombo'), 'L'},
		sizeRightHalf                   = {hs.settings.get('hotkeyCombo'), 'R'},
		sizeFull                        = {hs.settings.get('hotkeyCombo'), 'F'},
		sizeRight23rds                  = {hs.settings.get('hotkeyCombo'), 'N'},
		sizeLeft13rd                    = {hs.settings.get('hotkeyCombo'), 'M'},
		sizeLeft13rdTopHalfish          = {hs.settings.get('hotkeyCombo'), ','},
		sizeLeft13rdBottomHalfish       = {hs.settings.get('hotkeyCombo'), '.'},
		sizeCentered                    = {hs.settings.get('hotkeyCombo'), 'C'},
		sizeHalfHeightTopEdge           = {hs.settings.get('hotkeyCombo'), 'pad8'},
		sizeHalfHeightBottomEdge        = {hs.settings.get('hotkeyCombo'), 'pad2'},
		moveLeftEdge                    = {hs.settings.get('hotkeyCombo'), 'pad4'},
		moveRightEdge                   = {hs.settings.get('hotkeyCombo'), 'pad6'},
		sizeQ1                          = {hs.settings.get('hotkeyCombo'), 'pad9'},
		sizeQ2                          = {hs.settings.get('hotkeyCombo'), 'pad7'},
		sizeQ3                          = {hs.settings.get('hotkeyCombo'), 'pad1'},
		sizeQ4                          = {hs.settings.get('hotkeyCombo'), 'pad3'}
	},
	start = true
})

hs.spoons.use('SDCWorkspace', {
	config = {
		workspaces = {
			{
				title = '⌨️ Code',
				show = { 'Google Chrome', 'GitHub Desktop', 'Visual Studio Code', 'Hyper', 'TextEdit' },
				focus = { 'Visual Studio Code' },
				hide = { 'Tweetbot', 'Messages', 'Slack' },
				quit = {}
			},
			{
				title = '😁 Browse',
				show = { 'Google Chrome', 'Tweetbot' },
				focus = { 'Google Chrome' },
				hide = { 'GitHub Desktop', 'Code', 'Hyper' },
				quit = {}
			}
		}
	},
	hotkeys = {
		toggleChooser = {hs.settings.get('hotkeyCombo'), 'pad.'}
	}
})

hs.spoons.use('SDCHomeAssistant', {
	config = {
		api_domain = keys.homeassistant_api_domain,
		api_endpoint = keys.homeassistant_api_domain .. '/api/',
		api_key = keys.homeassistant_api_key
	},
	hotkeys = {
		switchLights = {hs.settings.get('hotkeyCombo'), 'f19'},
		turnOnSecondaryMonitor = {hs.settings.get('hotkeyCombo'), 'S'}
	},
	start = true
})

hs.spoons.use('SDCAudio', {
	config = {
		devices = {
			{
				order = 1,
				name = 'Built-in Output',
				menuIcon = '🖥',
				alertIcon = '🖥'
			},
			{
				order = 2,
				name = 'USB Audio Device',
				menuIcon = '🎧',
				alertIcon = '🎧'
			},
			{
				order = 3,
				name = 'Robert’s AirPods Pro',
				menuIcon = '🎧',
				alertIcon = '',
				overrides = 2
			}
		}
	},
	hotkeys = {
		switchAudio = {hs.settings.get('hotkeyCombo'), 'A'}
	},
	fn = function(thisSpoon)
		hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'f13', nil, function()
			thisSpoon.switchAudio()
		end)
	end,
	start = true
})

hs.spoons.use('SDCReminders', {
	hotkeys = {
		toggleWebview = {hs.settings.get('hotkeyCombo'), '9'}
	}
})

hs.spoons.use('SDCWeather', {
	config = {
		apiKey = keys.darksky_api_key,
		latitude = keys.latitude,
		longitude = keys.longitude
	},
	start = true
})

hs.spoons.use('SDCPhone', {
	config = {
		phoneNumbers = keys.phoneNumbers
	},
	hotkeys = {
		toggleChooser = {hs.settings.get('hotkeyCombo'), 'P'}
	},
	fn = function(thisSpoon)
		thisSpoon.setShortcuts()
	end
})

hs.spoons.use('SDCTimer', {
	config = {
		biz_api_key = keys.biz_api_key,
		biz_api_client_endpoint = keys.biz_api_client_endpoint
	},
	hotkeys = {
		toggleTimer = {hs.settings.get('hotkeyCombo'), '\\'}
	},
	fn = function(thisSpoon)
		hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'f14', nil, function()
			thisSpoon.toggleTimer()
		end)
	end
})

hs.spoons.use('SDCOvercast')
-- hs.spoons.use('SDCMusic', {
-- 	config = {
-- 		discogs_key = keys.discogs.key,
-- 		discogs_secret = keys.discogs.secret
-- 	}
-- })

-- hs.spoons.use('SDCDesktopCapture')
