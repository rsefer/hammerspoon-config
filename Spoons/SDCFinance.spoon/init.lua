--- === SDC Finance ===
local obj = {}
obj.__index = obj
obj.name = "SDCFinance"

local fontSize = 14.0

-- https://stackoverflow.com/a/10992898
function numWithCommas(n)
  return tostring(math.floor(n)):reverse():gsub('(%d%d%d)','%1,'):gsub(',(%-?)$','%1'):reverse()
end

function script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  return str:match("(.*/)")
end

function obj:updateTimerSet()
  obj.updateTimer = hs.timer.doEvery(obj.updateInterval, function()
    obj:updateAllCrypto()
  end)
end

function updateCrypto(currency, menu_item)
  status, data, headers = hs.http.get('https://api.coinmarketcap.com/v1/ticker/' .. currency .. '/?convert=' .. obj.localCurrency, {})
  if status == 200 then
    for k, v in pairs(hs.json.decode(data)) do
      for k2, v2 in pairs(v) do
        if k2 == obj.priceString then
          menuTitleString = math.floor(v2 * 1000) / 1000
        end
      end
    end
    menuTitle = ' ' .. numWithCommas(menuTitleString)
    if useIcons == false then
      menuTitle = currency .. menuTitle
    end
    menu_item:setTitle(hs.styledtext.new(menuTitle, { font = { size = fontSize } }))
  end
end

function obj:updateAllCrypto()
  for i, currency in ipairs(obj.cryptocurrencies) do
    updateCrypto(currency, obj.menusCrypto[i])
  end
end

function obj:buildCryptoMenus()
  for i, currency in ipairs(obj.cryptocurrencies) do
    obj.menusCrypto[i] = hs.menubar.new()
    local setMenu = function()
      hs.urlevent.openURL('https://coinmarketcap.com/assets/' .. currency .. '/')
    end
    obj.menusCrypto[i]:setClickCallback(setMenu)
    iconPathPrefix = script_path() .. 'images/'
    if currency == 'bitcoin' or currency == 'ethereum' then
      icon = hs.image.imageFromPath(iconPathPrefix .. currency .. '.pdf')
      obj.menusCrypto[i]:setIcon(icon:setSize({ w = fontSize, h = fontSize }))
    end
  end
end

function obj:setConfig(config)
  if config.currencies then
    obj.cryptocurrencies = config.currencies
  end
  if config.localCurrency then
    obj.localCurrency = config.localCurrency
    obj.priceString = 'price_' .. obj.localCurrency
  end
  if config.updateInterval then
    obj.updateInterval = config.updateInterval
  end
end

function obj:init()
  self.cryptocurrencies = {}
  self.localCurrency = 'usd'
  self.priceString = 'price_' .. self.localCurrency
  self.updateInterval = 60 * 5
  self.menusCrypto = {}
end

function obj:start()
  obj:buildCryptoMenus()
  obj:updateAllCrypto()
  obj.updateTimer = hs.timer.doEvery(obj.updateInterval, function()
    obj:updateAllCrypto()
  end)
end

function obj:stop()
  obj.updateTimer:stop()
  for i, menu in ipairs(obj.menusCrypto) do
    menu:removeFromMenuBar():delete()
  end
end

return obj
