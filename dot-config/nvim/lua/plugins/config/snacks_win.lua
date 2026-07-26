local M = { gh('folke/snacks.nvim') }

---@type snacks.Config
M.opts = {
  win = {
    border = vim.g.border,
  },
}

return M
