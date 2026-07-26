local M = { gh('aznhe21/actions-preview.nvim') }

M.event = 'LspAttach'

---@module 'actions-preview'
---@type table
M.opts = {
  backend = { 'snacks' },
  diff = {
    algorithm = 'patience',
    ctxlen = 3,
  },
  snacks = {
    layout = { preset = 'default' },
  },
}

return M
