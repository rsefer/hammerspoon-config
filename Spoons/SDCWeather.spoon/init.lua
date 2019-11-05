--- === SDC Weather ===
local obj = {}
obj.__index = obj
obj.name = "SDCWeather"

-- TODO: Consider switching to wttr.in

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
  status, data, headers = hs.http.get('https://api.darksky.net/forecast/' .. obj.apiKey .. '/' .. obj.latitude .. ',' .. obj.longitude, {})
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
  hs.urlevent.openURL('https://darksky.net/forecast/' .. obj.latitude .. ',' .. obj.longitude .. '/us12/en')
end

function obj:openDarkSkyDetails()
  hs.urlevent.openURL('https://darksky.net/details/' .. obj.latitude .. ',' .. obj.longitude .. '/' .. os.date('%Y-%m-%d') .. '/us12/en')
end

function obj:init()
	self.updateInterval = 60 * 15
	self.menuWeather = hs.menubar.new()
	self.weatherTimer = hs.timer.doEvery(obj.updateInterval, function()
		obj.updateWeather()
	end):stop()
end

function obj:start()
	location = hs.location.get()
	if location ~= nil then
    obj.latitude = location.latitude
		obj.longitude = location.longitude
	end
  obj:updateWeather()
	obj.weatherTimer:start()
end

function obj:stop()
  obj.weatherTimer:stop()
end

return obj
