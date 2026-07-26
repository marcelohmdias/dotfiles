local M = { gh('mason-org/mason.nvim') }

M.build = function()
  pcall(vim.cmd, 'MasonUpdate')
end

M.cmd = 'Mason'

M.keys = {
  { '<leader>cm', cmd('Mason'), desc = 'Mason' },
}

---@module 'mason'
---@type MasonSettings
M.opts = {
  ui = {
    border = vim.g.border,
    icons = {
      package_installed = '●',
      package_pending = '➜',
      package_uninstalled = '○',
    },
  },
}

return M
