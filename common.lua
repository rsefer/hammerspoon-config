function script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  return str:match("(.*/)")
end

function file_exists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

-- https://stackoverflow.com/a/10992898
function numWithCommas(n)
  return tostring(math.floor(n)):reverse():gsub('(%d%d%d)','%1,'):gsub(',(%-?)$','%1'):reverse()
end
