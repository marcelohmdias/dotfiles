local M = { gh('Bekaboo/dropbar.nvim') }

M.event = 'LazyFile'
M.name = 'dropbar'

---@module 'dropbar'
---@type dropbar_configs_t
M.opts = {
  icons = {
    kinds = {
      dir_icon = function()
        return nil, nil
      end,
    },
  },
  menu = {
    preview = false,
    scrollbar = { enable = false },
    win_configs = {
      border = vim.g.border,
    },
  },
  sources = {
    path = {
      preview = false,
    },
  },
}

return M
