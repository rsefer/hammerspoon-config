-- If providing a non-string, will assume hex code
-- https://mathew-kurian.github.io/CharacterMap/
-- starting at 5800
-- hexCode = 0x1001D3 of UNI1001D3.LARGE
-- /Library/Fonts/SF Pro
function textToImage(input, color)
	if type(input) == 'number' then
		input = utf8.char(input)
	end
	local styledInput = hs.styledtext.new(input, {
		font = {
			name = 'SF Pro',
			size = 100
		},
		color = color
	})
	local canvas = hs.canvas.new({ x = 0, y = 0, h = 0, w = 0 })
	canvas:size(canvas:minimumTextSize(styledInput))
		:appendElements({
			type = 'text',
			text = styledInput
		})
	return canvas:imageFromCanvas()
end

iconPause = textToImage(0x100285):setSize({ w = 24, h = 24 })
iconPlay = textToImage(0x100284):setSize({ w = 18, h = 18 })
iconTimerOff = textToImage(0x10042F):setSize({ w = 18, h = 18 })
iconTimerOn = textToImage(0x100430, { hex = '#1db954' }):setSize({ w = 18, h = 18 })
