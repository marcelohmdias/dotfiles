local str = require "utils.string"

local Utils = {}

function Utils:is_path(name)
  if name == nil then
    return false
  end
  return string.match(name, "/.+$")
end

function Utils:sanitize(name)
  local t = str:to_split(name, "[\\/]+")

  if t == nil then
    return name
  end

  local path = t[#t]

  if path == nil then
    return name
  end

  return "/" .. path
end

return Utils
