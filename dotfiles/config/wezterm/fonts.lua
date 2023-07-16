local wez = require 'wezterm'

local Font = {}

Font.fira_code = wez.font {
  family = 'FiraCode Nerd Font',
  harfbuzz_features = { 'cv06', 'cv25', 'cv26', 'cv28', 'cv32', 'ss01', 'ss04', 'ss07' }
}

Font.ubuntu = wez.font 'UbuntuMono Nerd Font'

Font.caskaydia = wez.font {
  family = 'CaskaydiaCove Nerd Font',
  harfbuzz_features = { 'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'zero', 'onum' }
}

Font.font_rules = {
  {
    intensity = 'Normal',
    italic = true,
    font = wez.font {
      family = 'CaskaydiaCove Nerd Font',
      harfbuzz_features = { 'ss01' },
      italic = true,
    },
  },
}

Font.size = 11.0

return Font
