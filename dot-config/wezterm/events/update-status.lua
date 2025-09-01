local wez = require "wezterm"
local Format = require "utils.format"

local M = {}

local get_left_status = function(enable)
  if enable then return Format:with_icon("leader", "") end
  return ""
end

local get_right_status = function(name)
  if name then return Format:to_format(name) end

  local time = wez.time.now()
  local calendar = Format:with_icon("calendar", time:format "%a, %d %b ")
  local clock = Format:with_icon("clock", time:format "%X")
  return calendar .. clock .. " "
end

local format_status = function(window)
  local left_status = get_left_status(window:leader_is_active())
  local right_status = get_right_status(window:active_key_table())
  window:set_left_status(Format:to_leader(left_status))
  window:set_right_status(Format:to_command(right_status))
end

function M.setup() wez.on("update-status", format_status) end

return M
