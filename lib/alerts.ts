type AlertOptions = {
	font?: HSFont;
	duration?: number;
	padding?: number;
};

export function initAlert(message: string, options: AlertOptions = {}) {
	const { font = HSFont.headline(), duration = 2, padding = 20 } = options;
	return hs.ui.alert(message)
		.font(font)
		.duration(duration)
		.padding(padding)
		.show();
}
