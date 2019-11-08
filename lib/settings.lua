hs.settings.set('hotkeyCombo', {'cmd', 'alt', 'ctrl'})
hs.settings.set('secondaryMonitorName', 'DELL P2415Q')
-- hs.settings.set('tertiaryMonitorName', 4128836) -- Duet doesn't have a name so we use the ID
hs.settings.set('tertiaryMonitorName', 'Yam Display')
hs.settings.set('screenClass', 'large') -- assumes large iMac
if string.match(string.lower(hs.host.localizedName()), 'macbook') then
  hs.settings.set('screenClass', 'small')
end

function gr(x, y, w, h)
	return x .. ',' .. y .. ', ' .. w .. 'x' .. h
end

fullWidth = 100
thirdCenterR = 66.6
thirdLeftR = fullWidth - thirdCenterR
thirdWidthRight = fullWidth - thirdCenterR

fullHeight = 56
halfHeightTop = fullHeight * 0.65
halfHeightBottom = fullHeight - halfHeightTop

hs.settings.set('windowSizes', {
	margin            = 24,
	full              = gr(0, 0, fullWidth, fullHeight),
	center            = gr(fullWidth / 5, fullHeight / 5, fullWidth * 3 / 5, fullHeight * 3 / 5),
	halves = {
		left            = gr(0, 0, fullWidth / 2, fullHeight),
		right           = gr(fullWidth / 2, 0, fullWidth / 2, fullHeight),
		leftTop         = gr(0, 0, fullWidth / 2, fullHeight)
	},
	thirds = {
		left            = gr(0, 0, thirdLeftR, fullHeight),
		center          = gr(thirdLeftR, 0, thirdLeftR, fullHeight),
		right           = gr(thirdCenterR, 0, thirdWidthRight, fullHeight),
		leftTop         = gr(0, 0, thirdWidthRight, halfHeightTop),
		leftBottom      = gr(0, halfHeightTop, thirdWidthRight, halfHeightBottom),
		rightTop        = gr(thirdCenterR, 0, thirdWidthRight, halfHeightTop),
		rightBottom     = gr(thirdCenterR, halfHeightTop, thirdWidthRight, halfHeightBottom),
		left2           = gr(0, 0, thirdCenterR, fullHeight),
		right2          = gr(fullWidth - thirdCenterR , 0, thirdCenterR, fullHeight)
	},
	quadrants = {
		one             = gr(fullWidth / 2, 0, fullWidth / 2, fullHeight / 2),
		two             = gr(0, 0, fullWidth / 2, fullHeight / 2),
		three           = gr(0, fullHeight / 2, fullWidth / 2, fullHeight / 2),
		four            = gr(fullWidth / 2, fullHeight / 2, fullWidth / 2, fullHeight / 2)
	}
})
hs.grid.setGrid(fullWidth .. 'x' .. fullHeight)
hs.grid.setMargins({
	x = hs.settings.get('windowSizes').margin,
	y = hs.settings.get('windowSizes').margin
})
hs.window.animationDuration = 0
-- hs.window.setFrameCorrectness = true
hs.grid.ui.textSize = 50
