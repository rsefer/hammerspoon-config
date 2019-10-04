-- To find Hammerspoon preferences:
-- 1) Run Hammerspoon from Spotlight or run `open -a Hammerspoon` in the Terminal
-- 2) Press Command + Comma

dofile('config.lua')
dofile('common.lua')

hs.settings.set('secondaryMonitorName', 'DELL P2415Q')
hs.settings.set('tertiaryMonitorName', 'Yam Display')

local hotkeyCombo = {'cmd', 'alt', 'ctrl'}
hs.settings.set('screenClass', 'large') -- assumes large iMac
if string.match(string.lower(hs.host.localizedName()), 'macbook') then
  hs.settings.set('screenClass', 'small')
end

-- Spoons
spoon = {} -- fixes global spoon loading issue

-- hs.spoons.use('SDCDesktopCapture')

hs.spoons.use('SDCWindows', {
	config = {
		watchedApps = {
			{
				names = {'Terminal'},
				small = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 },
				large = { x1 = 73, y1 = 0, w1 = 27, h1 = 100, nickname = '14th' },
				withMultipleMonitors = 'tertiary'
			},
			{
				names = {'TextEdit'},
				small = { x1 = 50, y1 = 0, w1 = 50, h1 = 100 },
				large = { x1 = 73, y1 = 60, w1 = 27, h1 = 40 },
				withMultipleMonitors = 'primary'
			},
			{
				names = {'Visual Studio Code', 'Code', 'Atom', 'GitHub Desktop'},
				delay = 1,
				small = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 },
				large = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 },
				withMultipleMonitors = 'secondary'
			},
			{
				names = {'Google Chrome'},
				delay = true,
				small = { x1 = 0, y1 = 0, w1 = 100, h1 = 100 },
				large = { x1 = 0, y1 = 0, w1 = 73, h1 = 100, nickname = '34ths' },
				withMultipleMonitors = 'primary'
			},
			{
				names = {'Tweetbot'},
				small = { x1 = 50, y1 = 0, w1 = 50, h1 = 100, doAfter = {
					x1 = 'opp', y1 = 'current', w1 = 'current', h1 = 'current'
				} },
				large = { x1 = 73, y1 = 0, w1 = 27, h1 = 55 },
				withMultipleMonitors = 'primary'
			}
		}
	},
	hotkeys = {
		resetWindows										= {hotkeyCombo, 'f18'},
		sizeLeftHalf                    = {hotkeyCombo, 'L'},
		sizeRightHalf                   = {hotkeyCombo, 'R'},
		sizeFull                        = {hotkeyCombo, 'F'},
		sizeCentered                    = {hotkeyCombo, 'C'},
		sizeLeft34ths                   = {hotkeyCombo, 'N'},
		size34thsCentered               = {hotkeyCombo, 'X'},
		sizeRight14th                   = {hotkeyCombo, 'M'},
		sizeRight14thTopHalfish         = {hotkeyCombo, ','},
		sizeRight14thBottomHalfish      = {hotkeyCombo, '.'},
		sizeHalfHeightTopEdge           = {hotkeyCombo, 'T'},
		sizeHalfHeightBottomEdge        = {hotkeyCombo, 'B'},
		moveLeftEdge                    = {hotkeyCombo, ';'},
		moveRightEdge                   = {hotkeyCombo, "'"}
	},
	start = true
})

hs.spoons.use('SDCHomeAssistant', {
	config = {
		api_endpoint = keys.homeassistant_api_endpoint,
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
		switchLights = {hotkeyCombo, 'f19'},
		turnOnSecondaryMonitor = {hotkeyCombo, 'S'}
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
		switchAudio = {hotkeyCombo, 'A'}
	},
	fn = function(thisSpoon)
		hs.hotkey.bind(hotkeyCombo, 'f13', nil, function()
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
		toggleWebview = {hotkeyCombo, 'f15'}
	}
})

hs.spoons.use('SDCReminders', {
	hotkeys = {
		toggleWebview = {hotkeyCombo, '9'}
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
		toggleChooser = {hotkeyCombo, 'P'}
	},
	fn = function(thisSpoon)
		thisSpoon.setShortcuts()
	end
})

hs.spoons.use('SDCTimer', {
	hotkeys = {
		toggleTimer = {hotkeyCombo, '\\'}
	},
	fn = function(thisSpoon)
		hs.hotkey.bind(hotkeyCombo, 'f14', nil, function()
			thisSpoon.toggleTimer()
		end)
	end,
	start = true
})

hs.spoons.use('SDCOvercast')
hs.spoons.use('SDCMusic', {
	config = {
		discogs_key = keys.discogs.key,
		discogs_secret = keys.discogs.secret
	}
})

-- New Google Calendar Event
hs.hotkey.bind(hotkeyCombo, '8', function()
	hs.urlevent.openURL('https://calendar.google.com/calendar/r/eventedit')
end)

-- Do Not Disturb toggle
-- (in Settings > Keyboard > Shortcuts)
-- {'cmd', 'alt', 'ctrl'}, f17

-- Dark Mode toggle
hs.hotkey.bind(hotkeyCombo, 'f16', function()
	hs.osascript.applescript([[
		tell application "System Events"
			tell appearance preferences
				set dark mode to not dark mode
			end tell
		end tell
	]])
end)

-- Force Quit Hammerspoon
-- (in Settings > Keyboard > Shortcuts)
-- {'cmd', 'alt', 'ctrl'}, -

-- Launch Hammerspoon
-- (in Settings > Keyboard > Shortcuts)
-- {'cmd', 'alt', 'ctrl'}, +

-- Mirror Display toggle
hs.hotkey.bind(hotkeyCombo, '0', function()
	hs.application.launchOrFocus('System Preferences')
	hs.timer.doAfter(3, function()
		hs.application.get('System Preferences'):selectMenuItem({'View', 'Displays'})
		hs.timer.doAfter(1, function()
			hs.window.focusedWindow():focusTab(2)
		end)
	end)
end)

-- Eject key puts computer to sleep
-- hs.eventtap.new({ hs.eventtap.event.types.NSSystemDefined }, function(event)
--	event = event:systemKey()
--	local next = next
--	if next(event) then
--		if event.key == 'EJECT' and event.down then
--			hs.caffeinate.systemSleep()
--		end
--	end
--end):start()

-- Watch Terminal app when (un)plugging iPad as monitor
hs.screen.watcher.new(function()
	terminal = hs.application.find('Terminal')
	tertiaryMonitor = hs.screen.find(hs.settings.get('tertiaryMonitorName'))
	if terminal:isRunning() then
		if tertiaryMonitor then
			hs.timer.doAfter(1, function()
				terminal:mainWindow():moveToScreen(tertiaryMonitor)
				spoon.SDCWindows:gridset(0, 0, 100, 100, nil, terminal)
			end)
		else
			hs.timer.doAfter(1, function()
				terminal:mainWindow():focus()
				spoon.SDCWindows:gridset(50, 0, 50, 100, nil, terminal)
				terminal:hide()
			end)
		end
	end
end):start()

-- Reload Hammerspoon
-- local reloadWatcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', hs.reload):start()
hs.hotkey.bind(hotkeyCombo, '/', function()
  hs.reload()
end)
hs.alert.show('Configuration loaded.')
