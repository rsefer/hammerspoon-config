-- -- Watch Terminal app when (un)plugging iPad as monitor
-- terminalWatcher = hs.screen.watcher.new(function()
-- 	terminal = hs.application.get('Terminal')
-- 	tertiaryMonitor = hs.screen.find(hs.settings.get('tertiaryMonitorName'))
-- 	if terminal:isRunning() then
-- 		if tertiaryMonitor then
-- 			hs.timer.doAfter(1, function()
-- 				terminal:mainWindow():moveToScreen(tertiaryMonitor)
-- 				terminal:mainWindow():moveToUnit(hs.layout.maximized)
-- 			end)
-- 		else
-- 			hs.timer.doAfter(1, function()
-- 				terminal:mainWindow():focus()
-- 				terminal:mainWindow():moveToUnit(hs.layout.right50)
-- 				terminal:hide()
-- 			end)
-- 		end
-- 	end
-- end)
-- terminalWatcher:start()

function sizeAdd(modal, key, size, size2)
	modal:bind('', key, nil, function()
		if size2 ~= nil then
			spoon.SDCWindows:windowMove(nil, nil, hs.settings.get('windowSizes')[size][size2])
		else
			spoon.SDCWindows:windowMove(nil, nil, hs.settings.get('windowSizes')[size])
		end
		modal:exit()
	end)
end

m = hs.hotkey.modal.new(hs.settings.get('hotkeyCombo'), 'pad0')
function m:entered() hs.timer.doAfter(3, function() m:exit() end) end

sizeAdd(m, 'pad.', 'thirds', 'right2')
sizeAdd(m, 'padenter', 'full')
sizeAdd(m, 'pad5', 'center')
sizeAdd(m, 'pad1', 'quadrants', 'three')

local wf = hs.window.filter
wf_browsers = wf.new({ 'Google Chrome', 'Firefox', 'Safari' })
	:subscribe(hs.window.filter.windowCreated, function(window, appName, event)
		spoon.SDCWindows:windowMove(window, nil, hs.settings.get('windowSizes').thirds.right2)
	end)
wf_terminal = wf.new(false):setAppFilter('Terminal')
	:subscribe({
		hs.window.filter.windowCreated,
		hs.window.filter.windowDestroyed
	}, function(window, appName, event)
		workingWindow = window
		app = hs.application.get(appName)
		if event == 'windowDestroyed' and app ~= nil and app:isRunning() then
			workingWindow = app:focusedWindow()
		end
		spoon.SDCWindows:moveWindowIfCloseToPreset(workingWindow)
	end)
	-- :subscribe(hs.window.filter.windowMoved, function()
	-- 	terminal = hs.application.get('Terminal')
	-- 	tertiaryMonitor = hs.screen.find(hs.settings.get('tertiaryMonitorName'))
	-- 	if tertiaryMonitor and terminal:mainWindow():screen() == tertiaryMonitor then
	-- 		win = terminal:mainWindow()
	-- 		winUR = win:frame():toUnitRect(win:screen():frame())
	-- 		if (winUR.w > 0.51 and winUR.w < 1.00) or (winUR.h > 0.50 and winUR.h < 0.97) then
	-- 			terminal:mainWindow():moveToUnit(hs.layout.maximized)
	-- 		end
	-- 	end
	-- end)
