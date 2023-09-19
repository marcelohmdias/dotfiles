local M = {}

function M:basename(s)
  if s == nil then return "" end
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

function M:is_path(name)
  if name == nil then return false end
  return string.match(name, "/.+$")
end

function M:sanitize(path)
  if path == nil or path == "" then return nil end

  local uri = "file://" .. os.getenv "HOME"

  if path == uri then return "~" end

  return "/" .. M:basename(path)
end

return M
