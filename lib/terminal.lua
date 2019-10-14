-- Watch Terminal app when (un)plugging iPad as monitor
terminalWatcher = hs.screen.watcher.new(function()
	terminal = hs.application.find('Terminal')
	tertiaryMonitor = hs.screen.find(hs.settings.get('tertiaryMonitorName'))
	if terminal:isRunning() then
		if tertiaryMonitor then
			hs.timer.doAfter(1, function()
				terminal:mainWindow():moveToScreen(tertiaryMonitor)
				terminal:mainWindow():moveToUnit(hs.layout.maximized)
			end)
		else
			hs.timer.doAfter(1, function()
				terminal:mainWindow():focus()
				terminal:mainWindow():moveToUnit(hs.layout.right50)
				terminal:hide()
			end)
		end
	end
end)
terminalWatcher:start()

local wf = hs.window.filter
wf_terminal = wf.new(false):setAppFilter('Terminal'):subscribe(hs.window.filter.windowMoved, function()
	terminal = hs.application.find('Terminal')
	tertiaryMonitor = hs.screen.find(hs.settings.get('tertiaryMonitorName'))
	if tertiaryMonitor and terminal:mainWindow():screen() == tertiaryMonitor then
		win = terminal:mainWindow()
		winUR = win:frame():toUnitRect(win:screen():frame())
		if (winUR.w > 0.51 and winUR.w < 1.00) or (winUR.h > 0.50 and winUR.h < 0.97) then
			terminal:mainWindow():moveToUnit(hs.layout.maximized)
		end
	end
end)
