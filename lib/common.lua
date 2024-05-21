function contains(table, val)
  for i = 1, #table do
    if table[i] == val then
      return true
    end
  end
  return false
end

function screenIsConnected(screenName)
	if hs.screen.find(screenName) ~= nil then
		return true
	else
		return false
	end
end

function screenChooser(options)
	desiredScreenName = options[hs.settings.get('deskSetup')]
	if desiredScreenName ~= nil then
		if type(desiredScreenName) == 'table' then
			for i, screen in ipairs(desiredScreenName) do
				if screenIsConnected(screen) then
					return hs.screen.find(screen)
				end
			end
		elseif screenIsConnected(desiredScreenName) then
			return hs.screen.find(desiredScreenName)
		end
	end
	return hs.screen.primaryScreen()
end

function windowSizeChooser(options)
	desiredSize = options[hs.settings.get('deskSetup')]
	if desiredSize ~= nil then
		return desiredSize
	else
		return hs.settings.get('windowSizes').center
	end
end
