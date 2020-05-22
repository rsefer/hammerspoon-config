iconSize = {
	w = hs.settings.get('menuIconSize'),
	h = hs.settings.get('menuIconSize')
}

iconPause = hs.image.imageFromASCII([[
	.1.4.a.d.
	.........
	.........
	.........
	.........
	.........
	.2.3.b.c.
]]):setSize(iconSize)

iconPlay = hs.image.imageFromASCII([[
	.........
	.1.......
	.........
	.........
	.......3.
	.........
	.........
	.2.......
	.........
]]):setSize(iconSize)