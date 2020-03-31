--- === SDC Weather ===
local obj = {}
obj.__index = obj
obj.name = "SDCWeather"

local function getWeatherIcon(iconSlug)
  iconLabel = '☁️'
  if iconSlug == 'partly-cloudy-day' or iconSlug == 'partly-cloudy-night' then
    iconLabel = '⛅️'
  elseif iconSlug == 'snow' then
    iconLabel = '❄️'
  elseif iconSlug == 'clear-day' then
    iconLabel = '☀️'
  elseif iconSlug == 'clear-night' then
    iconLabel = '🌙'
  elseif iconSlug == 'rain' or iconSlug == 'sleet' then
    iconLabel = '🌧'
  elseif iconSlug == 'fog' then
    iconLabel = '🌫'
  elseif iconSlug == 'wind' then
    iconLabel = '💨'
  end
  return iconLabel
end

function obj:updateWeather()
  status, data, headers = hs.http.get('https://api.darksky.net/forecast/' .. hs.settings.get('darksky_api_key') .. '/' .. hs.settings.get('latitude') .. ',' .. hs.settings.get('longitude'), {})
  if status == 200 then
    json = hs.json.decode(data)
    temperature = math.floor(json.currently.apparentTemperature)
    icon = json.currently.icon
    menuIconLabel = getWeatherIcon(icon)
    menuTable = {
      {
        title = 'darksky.net',
        fn = function() obj.openDarkSkyForecast() end
      },
      {
        title = '-'
			},
			{
				title = 'Feels like...',
				fn = function() obj.openDarkSkyDetails() end
			},
			{
        title = '-'
			}
    }
    for i = 1, 8 do
      hour = json.hourly.data[i]
      hourNumber = tonumber(os.date("%I", hour.time))
      hourLabel = hourNumber .. '' .. os.date("%p", hour.time):lower()
      if hourNumber < 10 then
        hourLabel = hourLabel .. ' '
      end
      table.insert(menuTable, {
        title = hourLabel .. "\t" .. getWeatherIcon(hour.icon) .. "\t" .. math.floor(hour.apparentTemperature) .. '°',
        fn = function() obj.openDarkSkyDetails() end
      })
    end
    obj.menuWeather:setTitle(menuIconLabel .. ' ' .. temperature .. '°')
    obj.menuWeather:setMenu(menuTable)
  end
end

function obj:openDarkSkyForecast()
  hs.urlevent.openURL('https://darksky.net/forecast/' .. hs.settings.get('latitude') .. ',' .. hs.settings.get('longitude') .. '/us12/en')
end

function obj:openDarkSkyDetails()
  hs.urlevent.openURL('https://darksky.net/details/' .. hs.settings.get('latitude') .. ',' .. hs.settings.get('longitude') .. '/' .. os.date('%Y-%m-%d') .. '/us12/en')
end

function obj:init()

	self.updateInterval = 60 * 15
	self.menuWeather = hs.menubar.new()
	self.weatherTimer = hs.timer.doEvery(obj.updateInterval, function()
		obj.updateWeather()
	end):stop()

	if setupSetting('darksky_api_key') then
		obj:start()
	end

end

function obj:start()
	if settingExists('latitude') and settingExists('longitude') then
		obj:updateWeather()
		obj.weatherTimer:start()
	else
		hs.alert.show('⛅️Cannot start weather timer - lat/lng not set')
	end
end

function obj:stop()
  obj.weatherTimer:stop()
end

return obj
