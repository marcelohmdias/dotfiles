local wez = require "wezterm"
local Format = require "utils.format"
local Path = require "utils.path"
local Proc = require "utils.process"

local M = {}

local get_left_status = function(enable)
  if enable then return Format:with_icon("leader", "") end
  return ""
end

local get_right_status = function(name)
  wez.log_info(name)
  if name then return Format:to_format(name) end

  local time = wez.time.now()
  local calendar = Format:with_icon("calendar", time:format "%a, %e %b")
  local clock = Format:with_icon("clock", time:format "%X")
  return calendar .. clock .. " "
end

local get_title = function(process, dir, name)
  process = Path:basename(process)

  if process ~= nil and process ~= "" and process ~= "bash" and process ~= "zsh" then
    return process
  end

  local children_process = Proc.get_info()

  if children_process ~= nil then return children_process end

  local dir_name = Path:sanitize(dir)

  if dir_name ~= nil then return dir_name end

  return name
end

function M.format_status(window, pane)
  local left_status = get_left_status(window:leader_is_active())
  local right_status = get_right_status(window:active_key_table())
  window:set_left_status(Format:to_leader(left_status))
  window:set_right_status(Format:to_command(right_status))
end

function M.format_title(tab)
  local pane = tab.active_pane
  local title = get_title(pane.foreground_process_name, pane.current_working_dir, pane.title)
  return Format:to_format(title)
end

return M
