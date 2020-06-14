--- === SDC Pasteboard ===
local obj = {}
obj.__index = obj
obj.name = "SDCPasteboard"

function obj:clearHistory()
	obj.pasteboardHistory = {}
	hs.settings.set('pasteboardHistory', obj.pasteboardHistory)
end

function obj:storeCopy()
	now = hs.pasteboard.changeCount()
	if now > obj.lastPasteboardChange then
		table.insert(obj.pasteboardHistory, 1, {
			content = hs.pasteboard.getContents() or '',
			timestamp = os.time(),
			contentTypes = hs.pasteboard.allContentTypes()[1],
			typesAvailable = hs.pasteboard.typesAvailable()
		})
		while (tablelength(obj.pasteboardHistory) >= 10) do
			table.remove(obj.pasteboardHistory, tablelength(obj.pasteboardHistory))
		end
		hs.settings.set('pasteboardHistory', obj.pasteboardHistory)
		obj.lastPasteboardChange = now
	end
end

function obj:populateChooser()
	titleMaxLength = 70
	ellipsesString = ' […]'
	choices = {}
	if tablelength(hs.settings.get('pasteboardHistory')) > 0 then
		for k, item in pairs(hs.settings.get('pasteboardHistory')) do
			icon = '📄'
			if string.sub(item.content, 1, 4) == 'http' or item.typesAvailable['URL'] ~= nil then
				icon = '🔗'
			elseif item.typesAvailable['image'] ~= nil then
				icon = '🖼️'
			elseif item.typesAvailable['styledText'] ~= nil then
				icon = '📝'
			end
			title = icon .. ' ' .. item.content
			if string.len(item.content) > titleMaxLength then
				title = title:gsub("\n", ""):gsub("\r", ""):gsub("\t", "")
				title = string.sub(title, 1, titleMaxLength - string.len(ellipsesString)) .. ellipsesString
			end
			table.insert(choices, {
				text = hs.styledtext.new(title, { font = { name = 'SF Mono' } }),
				subText = os.date('%I:%M%p', item.timestamp),
				timestamp = item.timestamp,
				fullText = item.content
			})
		end
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
		hs.pasteboard.writeObjects(choice.fullText)
		hs.eventtap.keyStroke('cmd', 'v')
		obj.lastPasteboardChange = hs.pasteboard.changeCount()
		choiceIndex = nil
		choiceItem = nil
		for k, item in pairs(obj.pasteboardHistory) do
			if item.timestamp == choice.timestamp then
				choiceIndex = k
				choiceItem = item
				break
			end
		end
		if choiceIndex ~= nil then
			table.remove(obj.pasteboardHistory, choiceIndex)
			table.insert(obj.pasteboardHistory, 1, choiceItem)
			hs.settings.set('pasteboardHistory', obj.pasteboardHistory)
		end
	end)
		:attachedToolbar(hs.webview.toolbar.new('pasteboardToolbar', {{
			id = 'pasteboardClear',
			label = 'Clear',
			selectable = true,
			fn = obj.clearHistory
		}}):sizeMode('small'):displayMode('label'))
		:width(self.chooserWidthPercentage)

	self.timer = hs.timer.new(1, self.storeCopy)

	self:populateChooser()

	hs.settings.watchKey('settings_pasteboardHistory_watcher', 'pasteboardHistory', obj.populateChooser)

end

function obj:start()
	obj.timer:start()
end

function obj:stop()
	obj.timer:stop()
end

return obj