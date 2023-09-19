local wez = require "wezterm"

local M = {}

M.font = wez.font {
  family = "FiraCode Nerd Font",
  harfbuzz_features = { "cv06", "cv25", "cv26", "cv28", "cv32", "ss01", "ss04", "ss07" },
}

M.font_rules = {
  {
    intensity = "Normal",
    italic = true,
    font = wez.font {
      family = "CaskaydiaCove Nerd Font",
      harfbuzz_features = { "ss01" },
      italic = true,
    },
  },
}

M.font_size = 11.0

return M
