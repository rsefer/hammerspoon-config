--- === SDC Desktop Capture ===
local obj = {}
obj.__index = obj
obj.name = "SDCDesktopCapture"

function obj:captureDesktop()

	local newFilePath = '~/Downloads/desktop.jpg'

	hs.osascript.applescript('do shell script "chflags hidden ~/Desktop/*"')
	hs.eventtap.keyStroke({'fn'}, 'f11')
	hs.alert('Capturing Desktop...', { textSize = 10, radius = 10, atScreenEdge = 1 })
	hs.timer.doAfter(2, function()
		local thisScreen = hs.screen.primaryScreen()
		local thisScreenFrame = thisScreen:frame()
		local padding = 15
		local frameCropped = hs.geometry.rect(thisScreenFrame.x + padding, thisScreenFrame.y + padding, thisScreenFrame.w - (padding * 2), thisScreenFrame.h - (padding * 2))
		thisScreen:shotAsJPG(newFilePath, frameCropped)
		hs.timer.doAfter(2, function()
			hs.alert('Desktop Captured')
			hs.eventtap.keyStroke({'fn'}, 'f11')
			hs.osascript.applescript('do shell script "chflags nohidden ~/Desktop/*"')
			hs.osascript.applescript('do shell script "open -a Mail ' .. newFilePath .. '"')
		end)
	end)

  return self

end

function obj:init()
	self.desktopCaptureMenu = hs.menubar.new()
		:setTitle('📸 Capture Desktop')
    :setClickCallback(obj.captureDesktop)
end

return obj
