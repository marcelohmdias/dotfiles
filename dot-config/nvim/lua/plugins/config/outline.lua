local M = { gh('hedyhli/outline.nvim') }

M.cmd = 'Outline'

-- stylua: ignore
M.keys = {
  { '<leader>cs', cmd('Outline'), desc = 'Toggle Outline' },
}

---@module 'outline'
---@type outline.Config
M.opts = function()
  local icons = require('core.icons')
  local defaults = require('outline.config').defaults
  local kind_icons = {}

  for kind, symbol in pairs(defaults.symbols.icons) do
    kind_icons[kind] = {
      icon = icons.kinds[kind] or symbol.icon,
      hl = symbol.hl,
    }
  end

  return {
    keymaps = {
      down_and_jump = '<down>',
      up_and_jump = '<up>',
    },
    symbol_folding = {
      autofold_depth = false,
    },
    symbols = {
      icons = kind_icons,
    },
  }
end

return M
