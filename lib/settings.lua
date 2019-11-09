hs.settings.set('hotkeyCombo', {'cmd', 'alt', 'ctrl'})
hs.settings.set('secondaryMonitorName', 'DELL P2415Q')
-- hs.settings.set('tertiaryMonitorName', 4128836) -- Duet doesn't have a name so we use the ID
hs.settings.set('tertiaryMonitorName', 'Yam Display')
hs.settings.set('screenClass', 'large') -- assumes large iMac
if string.match(string.lower(hs.host.localizedName()), 'macbook') then
  hs.settings.set('screenClass', 'small')
end

-- If gaps are not sized properly, it is likely due to windows
-- falling in between cells. Adjust dimensions accordingly
fullWidth = 100
thirdCenterY2 = 67
thirdLeftY2 = fullWidth - thirdCenterY2
thirdWidthRight = fullWidth - thirdCenterY2

fullHeight = 60
halfHeightTop = fullHeight * 0.65
halfHeightBottom = fullHeight - halfHeightTop

hs.settings.set('windowMargin', 24)
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
hs.grid.setMargins({
	x = hs.settings.get('windowMargin'),
	y = hs.settings.get('windowMargin')
})
hs.window.animationDuration = 0
-- hs.window.setFrameCorrectness = true
hs.grid.ui.textSize = 50
