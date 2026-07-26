local M = { gh('razak17/tailwind-fold.nvim') }

M.ft = { 'astro', 'html', 'javascriptreact', 'typescriptreact', 'vue' }

---@module 'tailwind-fold'
---@type table
M.opts = {
  enabled = true,
}

return M
