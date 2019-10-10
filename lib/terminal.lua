-- Watch Terminal app when (un)plugging iPad as monitor
terminalWatcher = hs.screen.watcher.new(function()
	terminal = hs.application.find('Terminal')
	tertiaryMonitor = hs.screen.find(hs.settings.get('tertiaryMonitorName'))
	if terminal:isRunning() then
		if tertiaryMonitor then
			hs.timer.doAfter(1, function()
				terminal:mainWindow():moveToScreen(tertiaryMonitor)
				spoon.SDCWindows:gridset(0, 0, 100, 100, nil, terminal)
			end)
		else
			hs.timer.doAfter(1, function()
				terminal:mainWindow():focus()
				spoon.SDCWindows:gridset(50, 0, 50, 100, nil, terminal)
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
		grid = hs.grid.get(terminal:mainWindow())
		if (grid.w > 50 and grid.w < 100) or (grid.h > 50 and grid.h < 97) then
			spoon.SDCWindows:gridset(0, 0, 100, 100, nil, terminal)
		end
	end
end)
