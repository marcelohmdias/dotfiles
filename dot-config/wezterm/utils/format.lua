local wez = require "wezterm"
local icons = require "utils.icons"
local Path = require "utils.path"

local M = {}

local get_icon = function(name)
  name = string.lower(name)

  if name:match "copy" then return icons.copy end
  if name:find("gh", 1, true) == 1 then return icons.gh end
  if name:match "%.sh$" then return icons.execute end
  if name == "~" then return icons.home end
  if Path:is_path(name) then return icons.folder end

  return icons[name] or icons.term
end

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
  local icon = get_icon(name)
  return " " .. icon .. sep .. str
end

return M
