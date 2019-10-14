-- hs.spoons.use('SDCDesktopCapture')

hs.spoons.use('SDCWindows', {
	config = {
		windowLayout = {
			{ 'Google Chrome', nil, hs.screen.primaryScreen(), hs.geometry.unitrect(0.00, 0.00, 0.73, 1.00) },
			{ 'Tweetbot', nil, hs.screen.primaryScreen(), hs.geometry.unitrect(0.73, 0.00, 0.27, 0.55) },
			{ 'TextEdit', nil, hs.screen.primaryScreen(), hs.geometry.unitrect(0.73, 0.60, 0.27, 0.40) },
			{ 'Code', nil, hs.settings.get('secondaryMonitorName'), hs.layout.maximized },
			{ 'GitHub Desktop', nil, hs.settings.get('secondaryMonitorName'), hs.layout.maximized },
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
		watchedApps = {
			{
				names = {'Terminal'},
				small = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 },
				large = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 },
				withMultipleMonitors = hs.screen.find(hs.settings.get('tertiaryMonitorName'))
			},
			{
				names = {'TextEdit'},
				small = { x1 = 50, y1 = 0, w1 = 50, h1 = 100 },
				large = { x1 = 73, y1 = 60, w1 = 27, h1 = 40 },
				withMultipleMonitors = hs.screen.primaryScreen()
			},
			{
				names = {'Visual Studio Code', 'Code', 'Atom', 'GitHub Desktop'},
				delay = 1,
				small = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 },
				large = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 },
				withMultipleMonitors = hs.screen.find(hs.settings.get('secondaryMonitorName'))
			},
			{
				names = {'Google Chrome'},
				delay = true,
				small = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 },
				large = { x1 = 0, y1 = 0, w1 = 73, h1 = 100, nickname = '34ths' },
				withMultipleMonitors = hs.screen.primaryScreen()
			},
			{
				names = {'Tweetbot'},
				small = { x1 = 73, y1 = 0, w1 = 27, h1 = 55 },
				large = { x1 = 73, y1 = 0, w1 = 27, h1 = 55 },
				withMultipleMonitors = hs.screen.primaryScreen()
			}
		}
	},
	hotkeys = {
		resetWindows										= {hs.settings.get('hotkeyCombo'), 'f18'},
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
		api_key = keys.homeassistant_api_key,
		watchedApps = {
			-- {
			--   name = 'Terminal',
			--   monitor = hs.settings.get('tertiaryMonitorName'),
			-- 	large = { x1 = 73, y1 = 0, w1 = 27, h1 = 100, nickname = '14th' }
			-- },
			{
				name = 'Visual Studio Code',
				monitor = hs.settings.get('secondaryMonitorName'),
				large = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 }
			},
			{
				name = 'Atom',
				monitor = hs.settings.get('secondaryMonitorName'),
				large = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 }
			},
			{
				name = 'GitHub Desktop',
				monitor = hs.settings.get('secondaryMonitorName'),
				large = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 }
			}
		}
	},
	hotkeys = {
		switchLights = {hs.settings.get('hotkeyCombo'), 'f19'},
		turnOnSecondaryMonitor = {hs.settings.get('hotkeyCombo'), 'S'}
	},
	fn = function(thisSpoon)
		thisSpoon.toggleSecondaryMonitor('on')
	end,
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
