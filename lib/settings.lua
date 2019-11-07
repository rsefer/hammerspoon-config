hs.settings.set('hotkeyCombo', {'cmd', 'alt', 'ctrl'})
hs.settings.set('secondaryMonitorName', 'DELL P2415Q')
-- hs.settings.set('tertiaryMonitorName', 4128836) -- Duet doesn't have a name so we use the ID
hs.settings.set('tertiaryMonitorName', 'Yam Display')
hs.settings.set('screenClass', 'large') -- assumes large iMac
if string.match(string.lower(hs.host.localizedName()), 'macbook') then
  hs.settings.set('screenClass', 'small')
end
hs.settings.set('windowSizes', {
	sizeCentered                    = {01.25, 01.25, 07.50, 07.50},
	sizeLeft34ths                   = {00.00, 00.00, 07.30, 10.00},
	size34thsCentered               = {01.25, 00.00, 07.30, 10.00},
	sizeRight14th                   = {07.30, 00.00, 02.70, 10.00},
	sizeRight14thTopHalfish         = {07.30, 00.00, 02.70, 05.50},
	sizeRight14thBottomHalfish      = {07.30, 06.00, 02.70, 04.00}
})
