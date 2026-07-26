local M = { gh('lewis6991/hover.nvim') }

M.event = 'LspAttach'

-- stylua: ignore
M.keys = {
  { 'K',           function() require('hover').open() end,   desc = 'Hover' },
  { 'gK',          function() require('hover').select() end, desc = 'Hover (select)' },
  { "<MouseMove>", function() require('hover').mouse() end,  desc = "hover.nvim",    mode = { "n" } },
}

---@module 'hover'
---@type Hover.UserConfig
M.opts = {
  mouse_delay = 1000,
  mouse_providers = {
    "LSP",
  },
  preview_opts = {
    border = vim.g.border,
  },
  preview_window = true,
  providers = {
    'hover.providers.lsp',
    'hover.providers.diagnostic',
  },
  title = true,
}

return M
