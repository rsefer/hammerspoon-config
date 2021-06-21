iconSize = {
	w = hs.settings.get('menuIconSize'),
	h = hs.settings.get('menuIconSize')
}

function symbolToImage(hexCode)
	local char = hs.styledtext.new(utf8.char(hexCode), {
		font = {
			name = 'SF Pro',
			size = 100
		}
	})
	local canvas = hs.canvas.new({ x = 0, y = 0, h = 0, w = 0 })
	canvas:size(canvas:minimumTextSize(char))
	canvas[#canvas + 1] = {
		type = 'text',
		text = char
	}
	return canvas:imageFromCanvas()
end

iconPause = symbolToImage(0x100285):setSize({ w = 24, h = 24 })
iconPlay = symbolToImage(0x100284):setSize({ w = 18, h = 18 })
