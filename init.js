// https://cmsj.github.io/Hammerspoon2/main/

function screenIsConnected(screenName) {
	return hs.screen.all()?.find(screen => screen.name === screenName) !== undefined;
}

console.log('Hammerspoon2 init.js loaded');
