hs.spoons.use('SDCPower', {
	start = true
})

hs.spoons.use('SDCWindows', {
	config = {
		windowLayout = {
			{
				apps = { 'Google Chrome', 'Brave', 'Safari', 'Firefox', 'Music', 'Spotify', 'Photos', 'App Store', 'Coda', 'TV', 'News', 'Podcasts', 'Postman' },
				screens = {
					deskWithiPad = nil,
					desk = nil,
					laptopWithiPad = nil,
					laptop = nil
				},
				sizes = {
					deskWithiPad = hs.settings.get('mainWindowDefaultSize'),
					desk = hs.settings.get('mainWindowDefaultSize'),
					laptopWithiPad = hs.settings.get('windowSizes').full,
					laptop = hs.settings.get('windowSizes').full,
				}
			},
			{
				apps = { 'Messages', 'Tweetbot', 'Home', 'Hammerspoon' },
				screens = {
					deskWithiPad = nil,
					desk = nil,
					laptopWithiPad = nil,
					laptop = nil
				},
				sizes = {
					deskWithiPad = hs.settings.get('windowSizes').thirds.rightTop,
					desk = hs.settings.get('windowSizes').thirds.rightTop,
					laptopWithiPad = hs.settings.get('windowSizes').thirds.right,
					laptop = hs.settings.get('windowSizes').thirds.right
				}
			},
			{
				apps = { 'Reminders', 'Slack' },
				screens = {
					deskWithiPad = nil,
					desk = nil,
					laptopWithiPad = nil,
					laptop = nil
				},
				sizes = {
					deskWithiPad = hs.settings.get('windowSizes').halves.right,
					desk = hs.settings.get('windowSizes').halves.right,
					laptopWithiPad = hs.settings.get('windowSizes').halves.right,
					laptop = hs.settings.get('windowSizes').halves.right
				}
			},
			{
				apps = { 'TextEdit', 'Notes' },
				screens = {
					deskWithiPad = nil,
					desk = nil,
					laptopWithiPad = nil,
					laptop = nil
				},
				sizes = {
					deskWithiPad = hs.settings.get('windowSizes').thirds.rightBottom,
					desk = hs.settings.get('windowSizes').thirds.rightBottom,
					laptopWithiPad = hs.settings.get('windowSizes').halves.right,
					laptop = hs.settings.get('windowSizes').halves.right
				}
			},
			{
				apps = { 'Photoshop', 'Illustrator', 'XD', 'Sketch' },
				screens = {
					deskWithiPad = nil,
					desk = nil,
					laptopWithiPad = nil,
					laptop = nil
				},
				sizes = {
					deskWithiPad = hs.settings.get('windowSizes').full,
					desk = hs.settings.get('windowSizes').full,
					laptopWithiPad = hs.settings.get('windowSizes').full,
					laptop = hs.settings.get('windowSizes').full
				}
			},
			{
				apps = { 'Local' },
				screens = {
					deskWithiPad = hs.settings.get('primaryMonitorName'),
					desk = hs.settings.get('primaryMonitorName'),
					laptopWithiPad = hs.settings.get('primaryMonitorName'),
					laptop = hs.settings.get('primaryMonitorName')
				},
				sizes = {
					deskWithiPad = hs.settings.get('windowSizes').full,
					desk = hs.settings.get('windowSizes').full,
					laptopWithiPad = hs.settings.get('windowSizes').full,
					laptop = hs.settings.get('windowSizes').full,
				}
			},
			{
				apps = { 'Code', 'GitHub Desktop' },
				screens = {
					deskWithiPad = hs.settings.get('primaryMonitorName'),
					desk = hs.settings.get('primaryMonitorName'),
					laptopWithiPad = hs.settings.get('tertiaryMonitorName'),
					laptop = hs.settings.get('primaryMonitorName')
				},
				sizes = {
					deskWithiPad = hs.settings.get('windowSizes').full,
					desk = hs.settings.get('windowSizes').full,
					laptopWithiPad = hs.settings.get('windowSizes').full,
					laptop = hs.settings.get('windowSizes').full
				}
			},
			{
				apps = { 'Terminal' },
				screens = {
					deskWithiPad = hs.settings.get('tertiaryMonitorName'),
					desk = hs.settings.get('secondaryMonitorName'),
					laptopWithiPad = hs.settings.get('tertiaryMonitorName'),
					laptop = hs.settings.get('primaryMonitorName')
				},
				sizes = {
					deskWithiPad = hs.settings.get('windowSizes').full,
					desk = hs.settings.get('windowSizes').thirds.rightTop,
					laptopWithiPad = hs.settings.get('windowSizes').full,
					laptop = hs.settings.get('windowSizes').halves.right
				}
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
	start = true
})

hs.spoons.use('SDCAudio', {
	config = {
		devices = {
			{
				order = 1,
				name = 'MacBook Pro Speakers',
				menuIcon = '📻',
				alertIcon = '📻'
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

-- hs.spoons.use('SDCOvercast')
hs.spoons.use('SDCMusic', {
	hotkeys = {
		spotifySwitchPlayer = {hs.settings.get('hotkeyCombo'), 'D'},
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

hs.spoons.use('SDCWorkspace', {
	config = {
		workspaces = {
			{
				title = '⌨️ Code',
				show = { 'Google Chrome', 'Brave', 'GitHub Desktop', 'Visual Studio Code', 'Terminal', 'TextEdit' },
				focus = { 'Visual Studio Code' },
				hide = { 'Tweetbot', 'Messages', 'Slack' },
				quit = {}
			},
			{
				title = '😁 Browse',
				show = { 'Google Chrome', 'Brave', 'Tweetbot' },
				focus = { 'Google Chrome', 'Brave' },
				hide = { 'GitHub Desktop', 'Code', 'Terminal' },
				quit = {}
			}
		}
	},
	hotkeys = {
		toggleChooser = {hs.settings.get('hotkeyCombo'), 'pad.'}
	},
	fn = function(thisSpoon)
		hs.hotkey.bind(hs.settings.get('hotkeyCombo'), 'w', nil, function()
			thisSpoon.toggleChooser()
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

hs.spoons.use('SDCPhone', {
	hotkeys = {
		toggleChooser = {hs.settings.get('hotkeyCombo'), 'P'}
	}
})

hs.spoons.use('SDCReminders', {
	hotkeys = {
		toggleWebview = {hs.settings.get('hotkeyCombo'), '9'}
	}
})
