import SDCWindows from './lib/SDCWindows.js';
import { defaults, deskLabels, setting } from './lib/defaults.js';

const sdcWindows = new SDCWindows();

if (hs.permissions.checkAccessibility()) {
	sdcWindows.start();
} else {
	hs.permissions.requestAccessibility();
	console.warn('Grant Accessibility permission to Hammerspoon 2, then reload this config.');
}

hs.hotkey.bind(defaults.hotkeyCombo, '/', () => {
	console.log('Hammerspoon is reloading');
	hs.reload();
});
hs.hotkey.bind(defaults.hotkeyCombo, '\\', () => sdcWindows.resetAllApps());
hs.urlevent.bind('reset_all_apps', () => sdcWindows.resetAllApps());
hs.urlevent.bind('reload_config', () => hs.reload());

hs.screen.on('change', () => sdcWindows.resetAllApps());
hs.userdefaults.on('deskSetup', value => sdcWindows.setDeskSetup(value));

const deskSetup = setting('deskSetup') as keyof typeof deskLabels;
hs.ui.alert(`Configuration loaded: ${deskLabels[deskSetup] || deskLabels.laptop}`).duration(2).show();
console.log('Hammerspoon 2 config loaded');
