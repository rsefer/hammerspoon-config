hs.settings.set('menuIconSize', 14.0)
hs.settings.set('musicPlayerName', 'Spotify')
hs.settings.set('hotkeyCombo', {'cmd', 'alt', 'ctrl'})
hs.settings.set('secondaryMonitorName', 'DELL P2415Q')
-- hs.settings.set('tertiaryMonitorName', 4128836) -- Duet doesn't have a name so we use the ID
hs.settings.set('tertiaryMonitorName', 'Yam Display')

hs.settings.watchKey('settings_deskSizeClass_watcher', 'deskSizeClass', function()
	hs.alert.show('Desk Size: ' .. hs.settings.get('deskSizeClass'), { atScreenEdge = 1 })
end)

hs.settings.set('windowGridFull', {
	width = 100,
	height = 60
})
hs.settings.set('windowMargin', {
	large = 18,
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
hs.grid.setGrid(fullWidth .. 'x' .. fullHeight)

hs.window.animationDuration = 0
-- hs.window.setFrameCorrectness = true
hs.grid.ui.textSize = 50
