local wez = require "wezterm"

local is_maple = true

local M = {}

local maple = {
  family = "Maple Mono NF Light",
  harfbuzz_features = { "zero", "cv01", "cv02", "cv03", "ss06", "ss08" },
}

local fira = {
  family = "FiraCode Nerd Font",
  harfbuzz_features = { "cv06", "cv25", "cv26", "cv28", "cv32", "ss01", "ss04", "ss07" },
}

M.font = wez.font(is_maple and maple or fira)

if not is_maple then
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
end

M.font_size = 13.0

return M
