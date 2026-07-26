local wez = require "wezterm"

local M = {}

local user_var_change = function(window, pane, name, value)
  local overrides = window:get_config_overrides() or {}
  if name == "ZEN_MODE" then
    local number_value = tonumber(value)
    if number_value < 0 then
      window:perform_action(wez.action.ResetFontSize, pane)
      overrides.font_size = nil
    else
      overrides.font_size = number_value
    end
  end
  window:set_config_overrides(overrides)
end

function M.setup() wez.on("user-var-changed", user_var_change) end

return M
