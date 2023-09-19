local wez = require "wezterm"
local Path = require "utils.path"
local Proc = wez.procinfo

local M = {}

local get_children = function(info)
  if info == nil or info.children == nil then return nil end

  for k, v in pairs(info.children) do
    if v ~= nil then return v end
  end

  return nil
end

function M.get_info()
  local info = Proc.get_info_for_pid(Proc.pid())
  local children = get_children(info)

  if children ~= nil then
    children = get_children(children)
    if children ~= nil then
      local argv = children.argv
      for k, v in pairs(argv) do
        if v ~= "sudo" then return Path:basename(v) end
      end
    end
  end

  return nil
end

return M
