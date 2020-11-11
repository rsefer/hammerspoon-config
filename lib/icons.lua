iconSize = {
	w = hs.settings.get('menuIconSize'),
	h = hs.settings.get('menuIconSize')
}

iconPause = hs.image.imageFromName(hs.image.systemImageNames.TouchBarPauseTemplate):setSize({ w = 30, h = 30 })

iconPlay = hs.image.imageFromName(hs.image.systemImageNames.TouchBarPlayTemplate):setSize({ w = 24, h = 24 })
