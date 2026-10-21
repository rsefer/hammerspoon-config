import SDCWindows from './lib/SDCWindows.js';
import { defaults, deskLabels, detectDeskSetup, setting } from './lib/defaults.js';
import { initAlert } from './lib/alerts.js';

hs.userdefaults.set('deskSetup', detectDeskSetup());
hs.userdefaults.set('deskSetupLabel', deskLabels[setting('deskSetup')]);
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

hs.screen.on('change', () => {
	const deskSetup = detectDeskSetup();
	if (deskSetup === sdcWindows.currentDeskSetup) sdcWindows.resetAllApps();
	else sdcWindows.setDeskSetup(deskSetup);
});
hs.userdefaults.on('deskSetup', value => sdcWindows.setDeskSetup(value));

const deskSetup = setting('deskSetup') as keyof typeof deskLabels;
initAlert(`Configuration loaded: ${deskLabels[deskSetup] || deskLabels.laptop}`, { font: HSFont.body() });
console.log('Hammerspoon 2 config loaded');
