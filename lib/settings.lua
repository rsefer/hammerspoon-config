hs.settings.set('menuIconSize', 14.0)
hs.settings.set('musicPlayerName', 'Spotify')
hs.settings.set('hotkeyCombo', {'cmd', 'alt', 'ctrl'})
hs.settings.set('primaryMonitorName', 'Color LCD') -- MacBook Pro screen
hs.settings.set('secondaryMonitorName', 'DELL P2415Q')
hs.settings.set('tertiaryMonitorName', 4128829) -- Sidecar Display
-- hs.settings.set('tertiaryMonitorName', 4128836) -- Duet
-- hs.settings.set('tertiaryMonitorName', 'Yam Display')

hs.settings.set('windowGridFull', {
	width = 100,
	height = 60
})
hs.settings.set('windowMargin', {
	large = 12,
	medium = 12,
	small = 0
})

-- If gaps are not sized properly, it is likely due to windows
-- falling in between cells. Adjust dimensions accordingly
fullWidth = hs.settings.get('windowGridFull').width
thirdCenterY2 = 67
thirdLeftY2 = fullWidth - thirdCenterY2
thirdWidthRight = fullWidth - thirdCenterY2

fullHeight = hs.settings.get('windowGridFull').height
halfHeightTop = fullHeight * 0.65
halfHeightBottom = fullHeight - halfHeightTop

function resetMacBookProScreen(sizing)
	hs.screen.find(hs.settings.get('primaryMonitorName')):setMode(sizing.width, sizing.height, sizing.scale)
end

function resetGrid()
	for x, screen in ipairs(hs.screen.allScreens()) do
		hs.grid.setGrid(hs.settings.get('windowGridFull').width .. 'x' .. hs.settings.get('windowGridFull').height, screen)
	end
end

function setAlertSize(size)
	if size == nil then
		size = 30
	end
	hs.alert.defaultStyle.textSize = size
end

resetGrid()
setAlertSize()

hs.settings.watchKey('settings_deskSetup_watcher', 'deskSetup', function()
	value = hs.settings.get('deskSetup')
	oldLabel = hs.settings.get('deskSetupLabel')
	if oldLabel == 'deskWithiPad' and value == 'laptopWithiPad' then
		hs.settings.set('deskSetup', 'laptop')
		return
	end
	alertSize = nil
	label = nil
	if value == 'deskWithiPad' then
		label = 'Desk with iPad'
		sizing = { width = 1792, height = 1120, scale = 2 }
		alertSize = 60
	elseif value == 'desk' then
		label = 'Desk'
		sizing = { width = 1792, height = 1120, scale = 2 }
		alertSize = 60
	elseif value == 'laptopWithiPad' then
		label = 'Laptop with iPad'
		sizing = { width = 2048, height = 1280, scale = 2 }
		alertSize = 30
	else
		label = 'Laptop'
		sizing = { width = 2048, height = 1280, scale = 2 }
		alertSize = 30
	end
	setAlertSize(alertSize)
	resetMacBookProScreen(sizing)
	hs.settings.set('deskSetupLabel', label)
	hs.alert.show('Desk Setup: ' .. hs.settings.get('deskSetupLabel'), { atScreenEdge = 1 })
	resetGrid()
	spoon.SDCWindows:resetAllApps()
end)

hs.settings.set('windowSizes', {
	full              = {0, 0, fullWidth, fullHeight},
	center            = {fullWidth / 5, fullHeight / 5, fullWidth * 3 / 5, fullHeight * 3 / 5},
	halves = {
		left            = {0, 0, fullWidth / 2, fullHeight},
		right           = {fullWidth / 2, 0, fullWidth / 2, fullHeight},
		leftTop         = {0, 0, fullWidth / 2, fullHeight}
	},
	thirds = {
		left            = {0, 0, thirdLeftY2, fullHeight},
		center          = {thirdLeftY2, 0, thirdLeftY2, fullHeight},
		right           = {thirdCenterY2, 0, thirdWidthRight, fullHeight},
		leftTop         = {0, 0, thirdWidthRight, halfHeightTop},
		leftBottom      = {0, halfHeightTop, thirdWidthRight, halfHeightBottom},
		rightTop        = {thirdCenterY2, 0, thirdWidthRight, halfHeightTop},
		rightBottom     = {thirdCenterY2, halfHeightTop, thirdWidthRight, halfHeightBottom},
		left2           = {0, 0, thirdCenterY2, fullHeight},
		right2          = {fullWidth - thirdCenterY2 , 0, thirdCenterY2, fullHeight}
	},
	quadrants = {
		one             = {fullWidth / 2, 0, fullWidth / 2, fullHeight / 2},
		two             = {0, 0, fullWidth / 2, fullHeight / 2},
		three           = {0, fullHeight / 2, fullWidth / 2, fullHeight / 2},
		four            = {fullWidth / 2, fullHeight / 2, fullWidth / 2, fullHeight / 2}
	}
})


hs.window.animationDuration = 0
-- hs.window.setFrameCorrectness = true
hs.grid.ui.textSize = 50
