-- Finance

---------------------------
--- Start Configuration ---
---------------------------

-- Equities to display (likely in reverse order)
local equities = {}--{'VTI'}

-- Cryptocurrencies to display (likely in reverse order)
-- Bitcoin: BTC
-- Ethereum: ETH
-- Litecoin: LTC
-- Golem: GNT
local cryptocurrencies = {'BTC', 'ETH'}
local localcurrency = 'USD'

-- Update interval (in seconds)
local updateInterval = 60 * 5

-- Aesthetics
local useColors = false
local useIcons = true
local fontSize = 14.0
local user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3095.5 Safari/537.36'

-------------------------
--- End Configuration ---
-------------------------

require 'common'

local lastValues = {}
local menusEquity = {}
local menusCrypto = {}
local updateTimer = nil

function updateTimerSet()
  updateTimer = hs.timer.doEvery(updateInterval, function()
    updateAllEquities()
    updateAllCrypto()
  end)
end

function updateEquity(symbol, menu_item)
  status, data, headers = hs.http.get("https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%20in%20(%22" .. symbol .. "%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys", {})
  if status == 200 then
    menuTitleString = ''
    for k, v in pairs(hs.json.decode(data)) do
      if k == 'query' and v and v.results and v.results.quote then
        menuTitleString = v.results.quote.ChangeinPercent
        break
      end
    end
    if menuTitleString == '' or menuTitleString == nil then
      menuTitleString = '?'
    end
    menuTitle = symbol .. ' ' .. menuTitleString
    menu_item:setTitle(hs.styledtext.new(menuTitle, {
      font = { size = fontSize },
      color = workingColor
    }))
  end
end

function updateCrypto(currency, menu_item)
  if currency == 'GNT' then
    status, data, headers = hs.http.get('https://api.coinmarketcap.com/v1/ticker/golem-network-tokens/?convert=' .. localcurrency, {})
    if status == 200 then
      for k, v in pairs(hs.json.decode(data)) do
        for k2, v2 in pairs(v) do
          if k2 == 'price_usd' then
            menuTitleString = math.floor(v2 * 1000) / 1000
          end
        end
      end
      menuTitle = ' ' .. menuTitleString
      if useIcons == false then
        menuTitle = currency .. menuTitle
      end
      menu_item:setTitle(hs.styledtext.new(menuTitle, {
        font = { size = fontSize },
        color = workingColor
      }))
      lastValues[currency] = currentValue
    end
  else
    status, data, headers = hs.http.get('https://api.gdax.com/products/' .. currency .. '-USD/stats', { ['User-Agent'] = user_agent })
    if status == 200 then
      json = hs.json.decode(data)
      workingColor = nil
      currentValue = tonumber(json['last'])
      if useColors then
        if lastValues[currency] and currentValue > lastValues[currency] then
          workingColor = { green = 1 }
        elseif lastValues[currency] and currentValue < lastValues[currency] then
          workingColor = { red = 1 }
        end
      end
      menuTitleString = numWithCommas(currentValue)

      menuTitle = ' ' .. menuTitleString
      if useIcons == false then
        menuTitle = currency .. menuTitle
      end
      menu_item:setTitle(hs.styledtext.new(menuTitle, {
        font = { size = fontSize },
        color = workingColor
      }))
      lastValues[currency] = currentValue
    end
  end
end

function updateAllEquities()
  for i, symbol in ipairs(equities) do
    updateEquity(symbol, menusEquity[i])
  end
end

function updateAllCrypto()
  for i, currency in ipairs(cryptocurrencies) do
    updateCrypto(currency, menusCrypto[i])
  end
end

function buildEquityMenus()
  for i, symbol in ipairs(equities) do
    menusEquity[i] = hs.menubar.new()
    local setMenu = function()
      urlString = 'https://invest.ameritrade.com/grid/p/site#r=jPage/https://research.ameritrade.com/grid/wwws/research/stocks/summary?symbol=' .. symbol
      hs.urlevent.openURL(urlString)
    end
    menusEquity[i]:setClickCallback(setMenu)
  end
end

function buildCryptoMenus()
  for i, currency in ipairs(cryptocurrencies) do
    menusCrypto[i] = hs.menubar.new()
    local setMenu = function()
      urlString = ''
      if currency == 'GNT' then
        urlString = 'https://coinmarketcap.com/assets/golem-network-tokens/'
      else
        urlString = 'https://www.gdax.com/trade/' .. currency .. '-' .. localcurrency
      end
      hs.urlevent.openURL(urlString)
    end
    menusCrypto[i]:setClickCallback(setMenu)
    if useIcons then
      iconPath = 'images/bitcoin.pdf'
      if currency == 'BTC' then
        iconPath = 'images/bitcoin.pdf'
      elseif currency == 'ETH' then
        iconPath = 'images/ethereum.pdf'
      elseif currency == 'GNT' then
        iconPath = 'images/golem.pdf'
      elseif currency == 'LTC' then
        iconPath = 'images/litecoin.pdf'
      end
      icon = hs.image.imageFromPath(iconPath)
      menusCrypto[i]:setIcon(icon:setSize({ w = fontSize, h = fontSize }))
    end
  end
end

buildEquityMenus()
buildCryptoMenus()
updateTimerSet()
updateAllEquities()
updateAllCrypto()
