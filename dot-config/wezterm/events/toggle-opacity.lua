local wez = require "wezterm"

local M = {}

local toggle_opacity = function(window)
  local overrides = window:get_config_overrides() or {}
  if overrides.window_background_opacity == 1.0 then
    overrides.window_background_opacity = 0.85
  else
    overrides.window_background_opacity = 1.0
  end
  window:set_config_overrides(overrides)
end

function M.setup() wez.on("toggle-opacity", toggle_opacity) end

return M
