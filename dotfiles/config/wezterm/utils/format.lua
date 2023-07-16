local wez = require 'wezterm'
local Config = require 'utils.config'
local Path = require 'utils.path'

local Utils = {}

function Utils:to_command(command)
  return wez.format {
    { Foreground = { Color = '#c6d0f5' } },
    { Text = command or '' }
  }
end

function Utils:to_format(str,  sep)
  local name = str

  if Path:is_path(str) then
    name = Path:sanitize(str)
  end

  return Utils:with_icon(str, name, sep) .. ' '
end

function Utils:to_leader(leader)
  return wez.format {
    { Foreground = { Color = '#292c3c' } },
    { Background = { Color = '#c6d0f5' } },
    { Text = leader or '' }
  }
end

function Utils:with_icon(name, str, sep)
  sep = sep or ' '
  local icon = Config:get_icon(name)
  return ' ' .. icon .. sep .. str
end

return Utils
