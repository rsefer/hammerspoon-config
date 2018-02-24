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

function obj:weatherTimerStart()
  obj.weatherTimer = hs.timer.doEvery(obj.updateInterval, function()
    obj.updateWeather()
  end)
end

function obj:weatherTimerStop()
  obj.weatherTimer:stop()
end

function obj:updateWeather()
  status, data, headers = hs.http.get('https://api.darksky.net/forecast/' .. obj.apiKey .. '/' .. obj.latitude .. ',' .. obj.longitude, {})
  if status == 200 then
    json = hs.json.decode(data)
    temperature = math.floor(json.currently.temperature)
    icon = json.currently.icon
    menuIconLabel = getWeatherIcon(icon)
    menuTable = {
      {
        title = 'darksky.net',
        fn = function() obj.openDarkSky() end
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
        title = hourLabel .. "\t" .. getWeatherIcon(hour.icon) .. "\t" .. math.floor(hour.temperature) .. '°',
        fn = function() obj.openDarkSky() end
      })
    end
    obj.menuWeather:setTitle(menuIconLabel .. ' ' .. temperature .. '°')
    obj.menuWeather:setMenu(menuTable)
  end
end

function obj:openDarkSky()
  hs.urlevent.openURL('https://darksky.net/forecast/' .. obj.latitude .. ',' .. obj.longitude .. '/us12/en')
end

function obj:setConfig(darksky_api_key, user_latitude, user_longitude)
  obj.apiKey = darksky_api_key
  if hs.location.get() ~= nil then
    loc = hs.location.get()
    obj.latitude = loc.latitude
    obj.longitude = loc.longitude
  elseif user_latitude ~= nil and user_longitude ~= nil then
    obj.latitude = user_latitude
    obj.longitude = user_longitude
  end
end

function obj:init()
  self.updateInterval = 60 * 15
  self.menuWeather = hs.menubar.new()
end

function obj:start(darksky_api_key, latitude, longitude)
  obj:setConfig(keys.darksky_api_key, keys.latitude, keys.longitude)
  obj:weatherTimerStart()
  obj:updateWeather()
end

function obj:stop()
  obj:weatherTimerStop()
end

return obj
