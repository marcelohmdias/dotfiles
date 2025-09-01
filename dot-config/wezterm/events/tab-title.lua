local wez = require "wezterm"
local Format = require "utils.format"
local Path = require "utils.path"
local Proc = require "utils.process"

local M = {}

local is_valid_name = function(name)
  return name ~= nil
    and name ~= ""
    and name ~= "gum"
    and name ~= "sesh"
    and name ~= "sudo"
    and name ~= "wezterm"
end

local get_title = function(process, name)
  local process_name = Path:basename(process)

  if is_valid_name(process_name) then return process_name end

  local children_process = Proc:get_info()
  if is_valid_name(children_process) then return children_process end

  return name
end

local format_title = function(tab)
  local pane = tab.active_pane
  local title = get_title(pane.foreground_process_name, pane.title)
  return Format:to_format(title)
end

function M.setup() wez.on("format-tab-title", format_title) end

return M
