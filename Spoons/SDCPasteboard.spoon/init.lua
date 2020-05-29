--- === SDC Pasteboard ===
local obj = {}
obj.__index = obj
obj.name = "SDCPasteboard"

function obj:storeCopy()
	now = hs.pasteboard.changeCount()
	if now > obj.lastPasteboardChange then
		currentClipboard = hs.pasteboard.getContents()
		table.insert(obj.pasteboardHistory, 1, {
			content = currentClipboard,
			timestamp = os.time()
		})
		while (tablelength(obj.pasteboardHistory) >= 10) do
			table.remove(obj.pasteboardHistory, tablelength(obj.pasteboardHistory))
		end
		hs.settings.set('pasteboardHistory', obj.pasteboardHistory)
		obj.lastPasteboardChange = now
	end
end

function obj:populatePasteboardChooser()
	if tablelength(hs.settings.get('pasteboardHistory')) == 0 then return end

	titleMaxLength = 70
	ellipsesString = ' [...]'
	choices = {}
	for k, item in pairs(hs.settings.get('pasteboardHistory')) do
		title = item.content
		if string.len(item.content) > titleMaxLength then
			title = title:gsub("\n", ""):gsub("\r", ""):gsub("\t", "")
			title = string.sub(title, 1, titleMaxLength - string.len(ellipsesString)) .. ellipsesString
		end
		table.insert(choices, {
			text = title,
			subText = os.date('%I:%M%p', item.timestamp),
			fullText = item.content
		})
	end
	obj.chooser:rows(tablelength(choices) + 1)
		:choices(choices)
end

function obj:toggleChooser()
	if obj.chooser:isVisible() then
		obj.chooser:hide()
	else
		if not hs.window.focusedWindow() then
			obj.chooser:show()
		else
			local focusedScreenFrame = hs.window.focusedWindow():screen():fullFrame()
			obj.chooser:show({ x = focusedScreenFrame.center.x - (obj.chooserWidthPercentage / 100 * focusedScreenFrame.w / 2), y = focusedScreenFrame.y })
		end
	end
end

function obj:bindHotkeys(mapping)
	hs.spoons.bindHotkeysToSpec({
		toggleChooser = hs.fnutils.partial(self.toggleChooser, self)
	}, mapping)
end

function obj:init()

	if not settingExists('pasteboardHistory') then
		hs.settings.set('pasteboardHistory', {})
	end

	self.chooserWidthPercentage = 35
	self.pasteboardHistory = hs.settings.get('pasteboardHistory')
	self.lastPasteboardChange = hs.pasteboard.changeCount()

	self.chooser = hs.chooser.new(function(choice)
		if not choice then return end
		hs.eventtap.keyStrokes(choice.fullText)
		hs.pasteboard.setContents(choice.fullText)
		obj.lastPasteboardChange = hs.pasteboard.changeCount()
	end)
		:attachedToolbar(hs.webview.toolbar.new('pasteboardToolbar', {{
			id = 'pasteboardClear',
			label = 'Clear',
			selectable = true,
			fn = function()
				obj.pasteboardHistory = {}
				hs.settings.set('pasteboardHistory', obj.pasteboardHistory)
			end
		}}):sizeMode('small'):displayMode('label'))
		:width(self.chooserWidthPercentage)

	self.timer = hs.timer.new(1, self.storeCopy)

	self:populatePasteboardChooser()

	hs.settings.watchKey('settings_pasteboardHistory_watcher', 'pasteboardHistory', function()
		obj:populatePasteboardChooser()
	end)

end

function obj:start()
	obj.timer:start()
end

function obj:stop()
	obj.timer:stop()
end

return obj
