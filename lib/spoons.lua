hs.spoons.use('SDCWindows', {
	config = {
		windowLayout = {
			{ 'Google Chrome', nil, hs.screen.primaryScreen(), hs.settings.get('windowSizes').sizeLeft34ths },
			{ 'Tweetbot', nil, hs.screen.primaryScreen(), hs.settings.get('windowSizes').sizeRight14thTopHalfish },
			{ 'Reminders', nil, hs.screen.primaryScreen(), hs.settings.get('windowSizes').sizeRight14thTopHalfish },
			{ 'TextEdit', nil, hs.screen.primaryScreen(), hs.settings.get('windowSizes').sizeRight14thBottomHalfish },
			{ 'Notes', nil, hs.screen.primaryScreen(), hs.settings.get('windowSizes').sizeRight14thBottomHalfish },
			{ 'Code', nil, hs.screen.find(hs.settings.get('secondaryMonitorName')), hs.layout.maximized },
			{ 'GitHub Desktop', nil, hs.screen.find(hs.settings.get('secondaryMonitorName')), hs.layout.maximized },
			{ 'Terminal', nil, function()
				if hs.screen.find(hs.settings.get('tertiaryMonitorName')) then
					return hs.screen.find(hs.settings.get('tertiaryMonitorName'))
				else
					return hs.screen.primaryScreen()
				end
			end, function(window)
				if hs.screen.find(hs.settings.get('tertiaryMonitorName')) then
					return hs.layout.maximized
				else
					return hs.layout.right50
				end
			end }
		},
	},
	hotkeys = {
		resetWindows                    = {hs.settings.get('hotkeyCombo'), 'f18'},
		sizeLeftHalf                    = {hs.settings.get('hotkeyCombo'), 'L'},
		sizeRightHalf                   = {hs.settings.get('hotkeyCombo'), 'R'},
		sizeFull                        = {hs.settings.get('hotkeyCombo'), 'F'},
		sizeCentered                    = {hs.settings.get('hotkeyCombo'), 'C'},
		sizeLeft34ths                   = {hs.settings.get('hotkeyCombo'), 'N'},
		size34thsCentered               = {hs.settings.get('hotkeyCombo'), 'X'},
		sizeRight14th                   = {hs.settings.get('hotkeyCombo'), 'M'},
		sizeRight14thTopHalfish         = {hs.settings.get('hotkeyCombo'), ','},
		sizeRight14thBottomHalfish      = {hs.settings.get('hotkeyCombo'), '.'},
		sizeHalfHeightTopEdge           = {hs.settings.get('hotkeyCombo'), 'T'},
		sizeHalfHeightBottomEdge        = {hs.settings.get('hotkeyCombo'), 'B'},
		moveLeftEdge                    = {hs.settings.get('hotkeyCombo'), ';'},
		moveRightEdge                   = {hs.settings.get('hotkeyCombo'), "'"}
	},
	start = true
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
				name = 'AirPods',
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

hs.spoons.use('SDCDash', {
	config = {
		dashWebviewHome = keys.dashHomeURL
	},
	hotkeys = {
		toggleWebview = {hs.settings.get('hotkeyCombo'), 'f15'}
	}
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
hs.spoons.use('SDCMusic', {
	config = {
		discogs_key = keys.discogs.key,
		discogs_secret = keys.discogs.secret
	}
})

-- hs.spoons.use('SDCDesktopCapture')
