hs.notify.withdrawAll()
hs.autoLaunch(true)
hs.location.start()
hs.window.filter.setLogLevel(1)
hs.hotkey.setLogLevel(1)
hs.console.darkMode(hs.host.interfaceStyle() == 'Dark')
hs.alert.defaultStyle.textSize = 40

if hs.updateAvailable() ~= false then
	hs.alert.show('Hammerspoon update available: ' .. hs.updateAvailable())
else
	hs.alert.show('Configuration loaded.')
end
