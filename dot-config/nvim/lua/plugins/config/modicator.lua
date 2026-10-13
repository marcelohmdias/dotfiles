local M = { gh('mawkler/modicator.nvim') }

-- Load after lualine so mode-highlight integration can pick up lualine colors.
M.event = 'VeryLazy'

M.dependencies = {
  gh('catppuccin/nvim'),
  gh('nvim-lualine/lualine.nvim'),
}

---@module 'modicator'
---@type modicator.Config
M.opts = {
  show_warnings = false,
  highlights = {
    defaults = {
      bold = false,
      italic = false,
    },
    use_cursorline_background = false,
  },
  integration = {
    lualine = {
      enabled = true,
      -- Use foreground because the current lualine setup places 'mode' in
      -- section `b`, whose background is the same across modes.
      highlight = 'fg',
    },
  },
}

return M
