local C = require("catppuccin.palettes").get_palette()

local M = { "akinsho/bufferline.nvim" }

--- @class bufferline.UserConfig
M.opts = {
  highlights = {
    indicator_selected = {
      fg = C.blue,
    },
  },
  options = {
    enforce_regular_tabs = true,
    indicator = {
      icon = "▎",
      style = "icon",
    },
    separator_style = { "", "" },
    show_buffer_icon = true,
    show_close_icon = true,
    show_tab_indicators = true,
  },
}

return M
