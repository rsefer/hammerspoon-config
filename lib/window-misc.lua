-- function sizeAdd(modal, key, size)
-- 	modal:bind('', key, nil, function()
-- 		spoon.SDCWindows:windowMove(nil, nil, size)
-- 		modal:exit()
-- 	end)
-- end

-- m = hs.hotkey.modal.new(hs.settings.get('hotkeyCombo'), 'pad0')
-- function m:entered() hs.timer.doAfter(3, function() m:exit() end) end

-- sizeAdd(m, 'pad.', hs.settings.get('windowSizes')['thirds']['right2'])
-- sizeAdd(m, 'padenter', hs.settings.get('windowSizes')['full'])
-- sizeAdd(m, 'pad5', hs.settings.get('windowSizes')['center'])
-- sizeAdd(m, 'pad1', hs.settings.get('windowSizes')['quadrants']['three'])

hs.window.filter.new({ 'TextEdit', 'Obsidian' })
	:subscribe(hs.window.filter.windowCreated, function(window, appName, event)
		if #hs.application.get(appName):allWindows() == 1 then
			if window:title() ~= 'Open' and (not window:tabCount() or window:tabCount() < 2) then
				spoon.SDCWindows:windowMove(window, nil, windowSizeChooser(spoon.SDCWindows:getAppLayoutSettings(appName).sizes))
			end
		end
	end)

hs.window.filter.new({ 'Google Chrome', 'Brave Browser', 'Firefox', 'Safari' })
	:subscribe(hs.window.filter.windowCreated, function(window, appName, event)
		spoon.SDCWindows:windowMove(window, nil, windowSizeChooser(spoon.SDCWindows:getAppLayoutSettings(appName).sizes))
	end)

hs.window.filter.new({ 'Terminal', 'iTerm2' })
	:subscribe({
		hs.window.filter.windowCreated,
		hs.window.filter.windowDestroyed
	}, function(window, appName, event)
		workingWindow = window
		app = hs.application.get(appName)
		if event == 'windowDestroyed' and app ~= nil and app:isRunning() then
			if (#app:allWindows() < 1) then
				return
			end
			workingWindow = app:focusedWindow()
		elseif event == 'windowCreated' and app ~= nil and app:isRunning() then
			if string.find(workingWindow:title(), '⌥⌘1') then -- hack to determine if window has only 1 tab
				spoon.SDCWindows:windowMove(workingWindow, nil, windowSizeChooser(spoon.SDCWindows:getAppLayoutSettings(hs.settings.get('terminalAppName')).sizes))
			end
		end
		spoon.SDCWindows:moveWindowIfCloseToPreset(workingWindow)
	end)
	:subscribe(hs.window.filter.windowMoved, function()
		terminal = hs.application.get(hs.settings.get('terminalAppName'))
		if tertiaryMonitor and terminal:mainWindow():screen() == hs.screen.find(hs.settings.get('tertiaryMonitorNames')) then
			win = terminal:mainWindow()
			winUR = win:frame():toUnitRect(win:screen():frame())
			if (winUR.w > 0.51 and winUR.w < 1.00) or (winUR.h > 0.50 and winUR.h < 0.97) then
				terminal:mainWindow():moveToUnit(hs.layout.maximized)
			end
		end
	end)
