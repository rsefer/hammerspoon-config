--- === SDC Pasteboard ===
local obj = {}
obj.__index = obj
obj.name = "SDCPasteboard"

function obj:clearHistory()
	obj.pasteboardHistory = {}
	hs.settings.set('pasteboardHistory', obj.pasteboardHistory)
end

function obj:populateChooser()
	titleMaxLength = 70
	ellipsesString = ' […]'
	choices = {}
	if tablelength(hs.settings.get('pasteboardHistory')) > 0 then
		for k, item in pairs(hs.settings.get('pasteboardHistory')) do
			title = item.content
			imageSymbol = '📄'
			if string.sub(item.content, 1, 4) == 'http' or item.typesAvailable['URL'] ~= nil then
				imageSymbol = '🔗'
			elseif item.typesAvailable['image'] ~= nil then
				imageSymbol = '🖼️'
				title = '[image]'
			elseif item.typesAvailable['styledText'] ~= nil then
				imageSymbol = '📝'
			end
			if string.len(item.content) > titleMaxLength then
				title = title:gsub("\n", ""):gsub("\r", ""):gsub("\t", "")
				title = string.sub(title, 1, titleMaxLength - string.len(ellipsesString)) .. ellipsesString
			end
			table.insert(choices, {
				text = hs.styledtext.new(title, { font = { name = 'SF Mono' } }),
				subText = os.date('%I:%M%p', item.timestamp),
				timestamp = item.timestamp,
				fullText = item.content,
				image = textToImage(imageSymbol)
			})
		end
	end
	obj.chooser:rows(tablelength(choices) + 2)
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

	self.chooser = hs.chooser.new(function(choice)
		if not choice then return end
		hs.pasteboard.writeObjects(choice.fullText)
		hs.eventtap.keyStroke('cmd', 'v')
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
			image = iconTrash,
			selectable = true,
			fn = obj.clearHistory
		}}):sizeMode('small'):displayMode('both'))
		:width(self.chooserWidthPercentage)

	self.watcher = hs.pasteboard.watcher.new(function(content)
		table.insert(obj.pasteboardHistory, 1, {
			content = content or '',
			timestamp = os.time(),
			contentTypes = hs.pasteboard.allContentTypes()[1],
			typesAvailable = hs.pasteboard.typesAvailable()
		})
		while (tablelength(obj.pasteboardHistory) >= 10) do
			table.remove(obj.pasteboardHistory, tablelength(obj.pasteboardHistory))
		end
		hs.settings.set('pasteboardHistory', obj.pasteboardHistory)
	end)

	self:populateChooser()

	hs.settings.watchKey('settings_pasteboardHistory_watcher', 'pasteboardHistory', obj.populateChooser)

end

function obj:start()
	obj.watcher:start()
end

function obj:stop()
	obj.watcher:stop()
end

return obj
