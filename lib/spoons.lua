hs.spoons.use('SDCWindows', {
	config = {
		windowLayout = {
			{
				apps = { 'Google Chrome', 'Brave Browser', 'Safari', 'Firefox', 'com.apple.Music', 'Spotify', 'Photos', 'App Store', 'Coda', 'com.apple.TV', 'com.apple.news', 'com.apple.podcasts', 'Postman', 'Basecamp 3', 'Shortcuts', 'Weather' },
				screens = {
					deskWithiPad = nil,
					desk = nil,
					laptopWithSide = nil,
					laptop = nil
				},
				sizes = {
					deskWithiPad = hs.settings.get('mainWindowDefaultSize'),
					desk = hs.settings.get('mainWindowDefaultSize'),
					laptopWithSide = hs.settings.get('windowSizes').full,
					laptop = hs.settings.get('windowSizes').full,
				}
			},
			{
				apps = { 'Messages', 'Twitter', 'com.apple.Home', 'Hammerspoon', 'Reminders', 'Slack', 'com.apple.Notes' },
				screens = {
					deskWithiPad = hs.settings.get('primaryMonitorName'),
					desk = hs.settings.get('primaryMonitorName'),
					laptopWithSide = nil,
					laptop = nil
				},
				sizes = {
					deskWithiPad = hs.settings.get('windowSizes').halves.left,
					desk = hs.settings.get('windowSizes').halves.left,
					laptopWithSide = hs.settings.get('windowSizes').thirds.right,
					laptop = hs.settings.get('windowSizes').thirds.right
				}
			},
			{
				apps = { 'Code', '1Password' },
				screens = {
					deskWithiPad = nil,
					desk = nil,
					laptopWithSide = nil,
					laptop = nil
				},
				sizes = {
					deskWithiPad = hs.settings.get('windowSizes').halves.right,
					desk = hs.settings.get('windowSizes').halves.right,
					laptopWithSide = hs.settings.get('windowSizes').halves.right,
					laptop = hs.settings.get('windowSizes').halves.right
				}
			},
			{
				apps = { 'io.robbie.HomeAssistant' },
				screens = {
					deskWithiPad = nil,
					desk = nil,
					laptopWithSide = nil,
					laptop = nil
				},
				sizes = {
					deskWithiPad = hs.settings.get('windowSizes').halves.right,
					desk = hs.settings.get('windowSizes').halves.right,
					laptopWithSide = hs.settings.get('windowSizes').full,
					laptop = hs.settings.get('windowSizes').full
				}
			},
			{
				apps = { 'TextEdit', 'Obsidian' },
				screens = {
					deskWithiPad = hs.settings.get('primaryMonitorName'),
					desk = hs.settings.get('primaryMonitorName'),
					laptopWithSide = nil,
					laptop = nil
				},
				sizes = {
					deskWithiPad = hs.settings.get('windowSizes').halves.left,
					desk = hs.settings.get('windowSizes').halves.left,
					laptopWithSide = hs.settings.get('windowSizes').halves.right,
					laptop = hs.settings.get('windowSizes').halves.right
				}
			},
			{
				apps = { 'Photoshop', 'Illustrator', 'XD', 'Sketch', 'UltiMaker Cura', 'Fusion 360' },
				screens = {
					deskWithiPad = nil,
					desk = nil,
					laptopWithSide = nil,
					laptop = nil
				},
				sizes = {
					deskWithiPad = hs.settings.get('windowSizes').full,
					desk = hs.settings.get('windowSizes').full,
					laptopWithSide = hs.settings.get('windowSizes').full,
					laptop = hs.settings.get('windowSizes').full
				}
			},
			{
				apps = { 'Spotify', 'Local', 'Fantastical', 'GitHub Desktop' },
				screens = {
					deskWithiPad = hs.settings.get('primaryMonitorName'),
					desk = hs.settings.get('primaryMonitorName'),
					laptopWithSide = hs.settings.get('primaryMonitorName'),
					laptop = hs.settings.get('primaryMonitorName')
				},
				sizes = {
					deskWithiPad = hs.settings.get('windowSizes').full,
					desk = hs.settings.get('windowSizes').full,
					laptopWithSide = hs.settings.get('windowSizes').full,
					laptop = hs.settings.get('windowSizes').full,
				}
			},
			{
				apps = { 'Spark', 'Spark Desktop', 'Mimestream' },
				screens = {
					deskWithiPad = hs.settings.get('primaryMonitorName'),
					desk = hs.settings.get('primaryMonitorName'),
					laptopWithSide = hs.settings.get('tertiaryMonitorNames'),
					laptop = hs.settings.get('primaryMonitorName')
				},
				sizes = {
					deskWithiPad = hs.settings.get('windowSizes').full,
					desk = hs.settings.get('windowSizes').full,
					laptopWithSide = hs.settings.get('windowSizes').full,
					laptop = hs.settings.get('windowSizes').full
				}
			},
			{
				apps = { 'Terminal', 'iTerm2', 'ChatGPT' },
				screens = {
					deskWithiPad =hs.settings.get('primaryMonitorName'),
					desk = hs.settings.get('primaryMonitorName'),
					laptopWithSide = hs.settings.get('primaryMonitorName'),
					laptop = hs.settings.get('primaryMonitorName')
				},
				sizes = {
					deskWithiPad = hs.settings.get('windowSizes').halves.right,
					desk = hs.settings.get('windowSizes').halves.right,
					laptopWithSide = hs.settings.get('windowSizes').full,
					laptop = hs.settings.get('windowSizes').halves.right
				}
			}
		},
		finickyApps = {
			'Terminal'
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
		-- sizeLeft13rd                    = {hs.settings.get('hotkeyCombo'), 'M'},
		-- sizeLeft13rdTopHalfish          = {hs.settings.get('hotkeyCombo'), ','},
		-- sizeLeft13rdBottomHalfish       = {hs.settings.get('hotkeyCombo'), '.'},
		-- sizeRight23rds                  = {hs.settings.get('hotkeyCombo'), 'N'},
		sizeRight13rd                   = {hs.settings.get('hotkeyCombo'), 'M'},
		sizeRight13rdTopHalfish         = {hs.settings.get('hotkeyCombo'), ','},
		sizeRight13rdBottomHalfish      = {hs.settings.get('hotkeyCombo'), '.'},
		sizeLeft23rds                   = {hs.settings.get('hotkeyCombo'), 'N'},
		sizeCentered                    = {hs.settings.get('hotkeyCombo'), 'C'},
		sizeHalfHeightTopEdge           = {hs.settings.get('hotkeyCombo'), 'pad8'},
		sizeHalfHeightBottomEdge        = {hs.settings.get('hotkeyCombo'), 'pad2'},
		moveLeftEdge                    = {hs.settings.get('hotkeyCombo'), 'pad4'},
		moveRightEdge                   = {hs.settings.get('hotkeyCombo'), 'pad6'},
		sizeQ1                          = {hs.settings.get('hotkeyCombo'), 'pad9'},
		sizeQ2                          = {hs.settings.get('hotkeyCombo'), 'pad7'},
		sizeQ3                          = {hs.settings.get('hotkeyCombo'), 'pad1'},
		sizeQ4                          = {hs.settings.get('hotkeyCombo'), 'pad3'},
		turnOnSecondaryMonitor          = {hs.settings.get('hotkeyCombo'), 'S'}
	},
	fn = function(thisSpoon)
		hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'f5', nil, function()
			thisSpoon.resetAllApps()
		end)
	end,
	start = true
})

-- hs.spoons.use('SDCMeetings', {
-- 	start = true
-- })

hs.spoons.use('SDCAudio', {
	config = {
		devices = {
			{
				order = 1,
				name = 'Studio Display Speakers',
				type = 'built-in',
				menuIcon = '🖥️',
				alertIcon = '🖥️'
			},
			{
				order = 2,
				name = 'MacBook Pro Speakers',
				type = 'built-in',
				menuIcon = '💻',
				alertIcon = '💻'
			},
			{
				order = 3,
				name = 'Robert’s AirPods Pro',
				type = 'headphones',
				menuIcon = '🎧',
				alertIcon = ''
			},
			{
				order = 4,
				name = 'Desk AirPods Pro',
				type = 'headphones',
				menuIcon = '🎧',
				alertIcon = ''
			},
			{
				order = 5,
				name = 'USB Audio Device',
				type = 'headphones',
				menuIcon = '🎧',
				alertIcon = '🎧'
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

hs.spoons.use('SDCTimer', {
	hotkeys = {
		toggleTimer = {hs.settings.get('hotkeyCombo'), '\\'},
		logTime = {hs.settings.get('hotkeyCombo'), ']'}
	},
	fn = function(thisSpoon)
		hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'f14', nil, function()
			thisSpoon.toggleTimer()
		end)
		hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'f15', nil, function()
			thisSpoon.logTime()
		end)
	end
})

-- hs.spoons.use('SDCOvercast', {
-- 	hotkeys = {
-- 		-- playerRewind = {hs.settings.get('hotkeyCombo'), 'pagedown'},
-- 		-- playerFastForward = {hs.settings.get('hotkeyCombo'), 'pageup'},
-- 	}
-- })
hs.spoons.use('SDCMusic', {
	hotkeys = {
		spotifySwitchPlayer = {hs.settings.get('hotkeyCombo'), 'I'},
		spotifyPlayPodcastEpisode = {hs.settings.get('hotkeyCombo'), 'P'},
		playerRewind = {hs.settings.get('hotkeyCombo'), 'pagedown'},
		playerFastForward = {hs.settings.get('hotkeyCombo'), 'pageup'},
	},
	fn = function(thisSpoon)
		hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'pad*', nil, function()
			thisSpoon.spotifySwitchPlayer()
		end)
	end,
	start = true
})

hs.spoons.use('SDCPasteboard', {
	hotkeys = {
		toggleChooser = {hs.settings.get('hotkeyCombo'), 'V'}
	},
	start = true
})

-- -- this is now covered by fanastical
-- hs.spoons.use('SDCReminders', {
-- 	hotkeys = {
-- 		toggleWebview = {hs.settings.get('hotkeyCombo'), '9'}
-- 	}
-- })
