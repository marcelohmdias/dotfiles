local wez = require "wezterm"
local Icon = require "utils.icons"

local M = {}

function M:to_command(command)
  return wez.format {
    { Foreground = { Color = "#c6d0f5" } },
    { Text = command or "" },
  }
end

function M:to_format(str, sep) return M:with_icon(str, str, sep) .. " " end

function M:to_leader(leader)
  return wez.format {
    { Foreground = { Color = "#292c3c" } },
    { Background = { Color = "#c6d0f5" } },
    { Text = leader or "" },
  }
end

function M:with_icon(name, str, sep)
  sep = sep or " "
  local icon = Icon:get_icon(name)
  return " " .. icon .. sep .. str
end

return M
