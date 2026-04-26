-- Diagnostic configuration
local icons = require('core.icons')

vim.diagnostic.config({
  float = {
    border = vim.g.border,
    focusable = true,
    source = true,
  },
  severity_sort = true,
  signs = {
    numhl = {
      [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
      [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
      [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
      [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
    },
    text = {
      [vim.diagnostic.severity.ERROR] = icons.alerts.error,
      [vim.diagnostic.severity.WARN] = icons.alerts.warn,
      [vim.diagnostic.severity.HINT] = icons.alerts.hint,
      [vim.diagnostic.severity.INFO] = icons.alerts.info,
    },
  },
  underline = true,
  update_in_insert = false,
  virtual_text = {
    current_line = true,
    prefix = icons.misc.bullet,
    spacing = 2,
  },
})
