hs.settings.set('menuIconSize', 14.0)
hs.settings.set('hotkeyCombo', {'cmd', 'alt', 'ctrl'})
hs.settings.set('primaryMonitorName', '37D8832A-2D66-02CA-B9F7-8F30A301B230') -- MacBook Pro screen
hs.settings.set('secondaryMonitorMain', 'Studio Display')
hs.settings.set('secondaryMonitorAlt', 'DELL P2415Q')
hs.settings.set('secondaryMonitorNames', { hs.settings.get('secondaryMonitorMain'), hs.settings.get('secondaryMonitorAlt') })
hs.settings.set('tertiaryMonitorNames', { 4128829, 3 }) -- Sidecar Display / Sidecar Display (AirPlay)
-- Sidecar Display / Sidecar Display (AirPlay) / ID: 4128829
-- RTKFHD / ID: 3 / UUID: EAD6D7D6-AB53-4D20-8337-F301D398F377
hs.settings.set('terminalAppName', 'iTerm2')

hs.settings.set('windowGridFull', {
	width = 100,
	height = 60
})
hs.settings.set('windowMargin', {
	large = 8,
	medium = 8,
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

function resetGrid()
	for x, screen in ipairs(hs.screen.allScreens()) do
		hs.grid.setGrid(hs.settings.get('windowGridFull').width .. 'x' .. hs.settings.get('windowGridFull').height, screen)
	end
end

function setAlertSize(size)
	hs.alert.defaultStyle.textSize = size or 30
end

resetGrid()
setAlertSize()

hs.settings.watchKey('settings_deskSetup_watcher', 'deskSetup', function()
	value = hs.settings.get('deskSetup')
	oldLabel = hs.settings.get('deskSetupLabel')
	if oldLabel == 'deskWithiPad' and value == 'laptopWithSide' then
		hs.settings.set('deskSetup', 'laptop')
		return
	end
	alertSize = nil
	label = nil
	-- sizeLaptop = { width = 1512, height = 982, scale = 2, freq = 120, depth = 8 }
	-- sizeDesktop = { width = 1792, height = 1120, scale = 2, freq = 120, depth = 8 }
	if value == 'deskWithiPad' then
		label = 'Desk with iPad'
		-- sizing = sizeDesktop
		alertSize = 45
	elseif value == 'desk' then
		label = 'Desk'
		-- sizing = sizeDesktop
		alertSize = 45
	elseif value == 'laptopWithSide' then
		label = 'Laptop with Side Monitor'
		-- sizing = sizeLaptop
		alertSize = 30
	else
		label = 'Laptop'
		-- sizing = sizeLaptop
		alertSize = 30
	end
	setAlertSize(alertSize)
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

hs.settings.set('mainWindowDefaultSize', hs.settings.get('windowSizes').halves.left)

hs.window.animationDuration = 0
-- hs.window.setFrameCorrectness = true
hs.grid.ui.textSize = 50
