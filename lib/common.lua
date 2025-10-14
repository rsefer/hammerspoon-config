function combineLists(list1, list2)
  for i = 1, #list2 do
    list1[#list1 + 1] = list2[i]
  end
  return list1
end

function mapList(originalList, key)
	local newList = {}
	for _, item in ipairs(originalList) do
		table.insert(newList, item[key])
	end
	return newList
end

function contains(table, val)
  for i = 1, #table do
    if table[i] == val then
      return true
    end
  end
  return false
end

function tableIntersection(table1, table2)
	local intersection = {}
	local set = {}
	for _, value in ipairs(table1) do
		set[value] = true
	end
	for _, value in ipairs(table2) do
		if set[value] then
			table.insert(intersection, value)
		end
	end
	return intersection
end

function findByKeyValue(arr, key, value)
	for i, item in ipairs(arr) do
		if item[key] == value then
			return item
		end
	end
	return nil
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

function browsers()
	return {
		{
			name = 'Safari',
			appBundleID = 'com.apple.Safari'
		},
		{
			name = 'Google Chrome',
			appBundleID = 'com.google.Chrome'
		},
		{
			name = 'Firefox',
			appBundleID = 'org.mozilla.firefox'
		},
		{
			name = 'Vivaldi',
			appBundleID = 'com.vivaldi.Vivaldi',
			ignoreWindowTitles = { 'Updating Vivaldi' }
		},
		{
			name = 'Orion',
			appBundleID = 'com.kagi.kagimacOS',
			ignoreWindowTitles = { 'Untitled', 'Completions' }
		},
		{
			name = 'Zen',
			appBundleID = 'app.zen-browser.zen'
		},
		{
			name = 'Brave Browser',
			appBundleID = 'com.brave.Browser'
		},
		{
			name = 'Google Chrome Canary',
			appBundleID = 'com.google.Chrome.canary'
		},
		{
			name = 'Microsoft Edge',
			appBundleID = 'com.microsoft.edgemac'
		},
		{
			name = 'Arc',
			appBundleID = 'company.thebrowser.Browser'
		}
	}
end
