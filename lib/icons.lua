-- https://mathew-kurian.github.io/CharacterMap/
-- starting at 5800
-- hexCode = 0x1001D3 of UNI1001D3.LARGE
-- /Library/Fonts/SF Pro
function symbolToImage(hexCode, color)
	local char = hs.styledtext.new(utf8.char(hexCode), {
		font = {
			name = 'SF Pro',
			size = 100
		},
		color = color
	})
	local canvas = hs.canvas.new({ x = 0, y = 0, h = 0, w = 0 })
	canvas:size(canvas:minimumTextSize(char))
	canvas[#canvas + 1] = {
		type = 'text',
		text = char
	}
	return canvas:imageFromCanvas()
end

iconSize = {
	w = hs.settings.get('menuIconSize'),
	h = hs.settings.get('menuIconSize')
}

iconPause = symbolToImage(0x100285):setSize({ w = 24, h = 24 })
iconPlay = symbolToImage(0x100284):setSize({ w = 18, h = 18 })
iconTimerOff = symbolToImage(0x10042F):setSize(iconSize)
iconTimerOn = symbolToImage(0x100430, { hex = '#1db954' }):setSize(iconSize)
