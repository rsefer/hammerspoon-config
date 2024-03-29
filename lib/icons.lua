-- If providing a non-string, will assume hex code
-- https://mathew-kurian.github.io/CharacterMap/
-- starting at 6994
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
iconTimerOnAlt = textToImage(0x100430, { hex = '#f9ff31' })
iconTimerSuccess = textToImage(0x100E74, { hex = '#1db954' })
iconTimerFail = textToImage(0x100E76, { hex = '#ff0000' })
iconTimerAlt = textToImage(0x1011B8, { hex = '#cccccc' })
iconCalendar = textToImage(0x100249)
iconVideoWhite = textToImage(0x10034A, { hex = '#ffffff' })
iconBriefcase = textToImage(0x100D8A, { hex = '#1db954' })
iconHouse = textToImage(0x10039F, { hex = '#ff3333' })
iconNew = textToImage(0x10020E)
iconNote = textToImage(0x10020F)
iconRefresh = textToImage(0x10037F)
iconTrash = textToImage(0x100211)
iconAirpodsPro = textToImage(0x100AB7)
