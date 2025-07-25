hs.spoons.use('SDCWindows', {
	config = {
		windowLayout = {
			{
				apps = combineLists(
					combineLists(mapList(browsers(), 'appBundleID'), mapList(browsers(), 'name')),
					{'Fiery Feeds', 'com.apple.Music', 'Spotify', 'Photos', 'App Store', 'Coda', 'com.apple.TV', 'com.apple.news', 'com.apple.podcasts', 'Postman', 'Shortcuts', 'Weather'}
				),
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
				apps = { 'Messages', 'Twitter', 'X', 'com.apple.Home', 'Hammerspoon', 'Reminders', 'Slack', 'com.apple.Notes' },
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
					laptopWithSide = hs.settings.get('tertiaryMonitorNames'),
					laptop = nil
				},
				sizes = {
					deskWithiPad = hs.settings.get('windowSizes').halves.right,
					desk = hs.settings.get('windowSizes').halves.right,
					laptopWithSide = hs.settings.get('windowSizes').full,
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
				apps = { 'Photoshop', 'Illustrator', 'XD', 'UltiMaker Cura', 'Fusion 360' },
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
		resetWindows                    = {hs.settings.get('hotkeyCombo'), '\\'},
		-- moveWindowRightScreen           = {hs.settings.get('hotkeyCombo'), 'right'},
		-- moveWindowLeftScreen            = {hs.settings.get('hotkeyCombo'), 'left'},
		-- moveWindowUpScreen              = {hs.settings.get('hotkeyCombo'), 'up'},
		-- moveWindowDownScreen            = {hs.settings.get('hotkeyCombo'), 'down'},
		-- sizeLeftHalf                    = {hs.settings.get('hotkeyCombo'), 'L'},
		-- sizeRightHalf                   = {hs.settings.get('hotkeyCombo'), 'R'},
		-- sizeFull                        = {hs.settings.get('hotkeyCombo'), 'F'},
		-- sizeLeft13rd                    = {hs.settings.get('hotkeyCombo'), 'M'},
		-- sizeLeft13rdTopHalfish          = {hs.settings.get('hotkeyCombo'), ','},
		-- sizeLeft13rdBottomHalfish       = {hs.settings.get('hotkeyCombo'), '.'},
		-- sizeRight23rds                  = {hs.settings.get('hotkeyCombo'), 'N'},
		-- sizeRight13rd                   = {hs.settings.get('hotkeyCombo'), 'M'},
		-- sizeRight13rdTopHalfish         = {hs.settings.get('hotkeyCombo'), ','},
		-- sizeRight13rdBottomHalfish      = {hs.settings.get('hotkeyCombo'), '.'},
		-- sizeLeft23rds                   = {hs.settings.get('hotkeyCombo'), 'N'},
		-- sizeCentered                    = {hs.settings.get('hotkeyCombo'), 'C'},
		-- sizeHalfHeightTopEdge           = {hs.settings.get('hotkeyCombo'), 'pad8'},
		-- sizeHalfHeightBottomEdge        = {hs.settings.get('hotkeyCombo'), 'pad2'},
		-- moveLeftEdge                    = {hs.settings.get('hotkeyCombo'), 'pad4'},
		-- moveRightEdge                   = {hs.settings.get('hotkeyCombo'), 'pad6'},
		-- sizeQ1                          = {hs.settings.get('hotkeyCombo'), 'pad9'},
		-- sizeQ2                          = {hs.settings.get('hotkeyCombo'), 'pad7'},
		-- sizeQ3                          = {hs.settings.get('hotkeyCombo'), 'pad1'},
		-- sizeQ4                          = {hs.settings.get('hotkeyCombo'), 'pad3'},
	},
	start = true
})
