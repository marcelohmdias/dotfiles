local wez = require "wezterm"
local Path = require "utils.path"
local Proc = wez.procinfo

local M = {}

local commandList = {
  ["sesh"] = "tmux",
}

local get_children = function(info)
  if info == nil or info.children == nil then return nil end

  for _, v in pairs(info.children) do
    if v ~= nil then return v end
  end

  return nil
end

function M:get_info()
  local info = Proc.get_info_for_pid(Proc.pid())
  local children = get_children(info)

  if children ~= nil then
    children = get_children(children)
    if children ~= nil then
      local argv = children.argv
      local command = argv[1]

      if command == "sudo" then command = argv[2] end
      if command == "gum" then command = argv[9] end

      local name = commandList[command]
      if name ~= nil then command = name end

      return Path:basename(command)
    end
  end

  return nil
end

return M
