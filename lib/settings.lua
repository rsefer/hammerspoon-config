hs.settings.set('hotkeyCombo', {'cmd', 'alt', 'ctrl'})
hs.settings.set('secondaryMonitorName', 'DELL P2415Q')
-- hs.settings.set('tertiaryMonitorName', 4128836) -- Duet doesn't have a name so we use the ID
hs.settings.set('tertiaryMonitorName', 'Yam Display')
hs.settings.set('screenClass', 'large') -- assumes large iMac
if string.match(string.lower(hs.host.localizedName()), 'macbook') then
  hs.settings.set('screenClass', 'small')
end
