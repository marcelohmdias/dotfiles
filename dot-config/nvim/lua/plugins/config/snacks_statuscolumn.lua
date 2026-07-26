local M = { gh('folke/snacks.nvim') }

---@type snacks.Config
M.opts = {
  statuscolumn = {
    enabled = true,
    left = { 'mark', 'fold', 'sign' },
    right = { 'git' },
    folds = { open = true },
  },
}

return M
