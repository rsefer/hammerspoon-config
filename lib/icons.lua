iconSize = {
	w = hs.settings.get('menuIconSize'),
	h = hs.settings.get('menuIconSize')
}

iconPause = hs.image.imageFromName(hs.image.systemImageNames.TouchBarPauseTemplate):setSize({ w = 32, h = 32 })

iconPlay = hs.image.imageFromName(hs.image.systemImageNames.TouchBarPlayTemplate):setSize({ w = 24, h = 24 })
