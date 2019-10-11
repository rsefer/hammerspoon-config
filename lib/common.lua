function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function urlencode(url)
	-- https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99
  if url == nil then
    return
  end
  url = url:gsub("\n", "\r\n")
  url = url:gsub(" ", "+")
  return url
end

function tablelength(t)
	local count = 0
	for _ in pairs(t) do count = count + 1 end
	return count
end
