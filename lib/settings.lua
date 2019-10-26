hs.settings.set('hotkeyCombo', {'cmd', 'alt', 'ctrl'})
hs.settings.set('secondaryMonitorName', 'DELL P2415Q')
-- hs.settings.set('tertiaryMonitorName', 4128836) -- Duet doesn't have a name so we use the ID
hs.settings.set('tertiaryMonitorName', 'Yam Display')
hs.settings.set('screenClass', 'large') -- assumes large iMac
if string.match(string.lower(hs.host.localizedName()), 'macbook') then
  hs.settings.set('screenClass', 'small')
end
hs.settings.set('windowSizes', {
	sizeCentered                    = {0.125, 0.125, 0.750, 0.750},
	sizeLeft34ths                   = {0.000, 0.000, 0.730, 1.000},
	size34thsCentered               = {0.125, 0.000, 0.730, 1.000},
	sizeRight14th                   = {0.730, 0.000, 0.270, 1.000},
	sizeRight14thTopHalfish         = {0.730, 0.000, 0.270, 0.550},
	sizeRight14thBottomHalfish      = {0.730, 0.600, 0.270, 0.400}
})
