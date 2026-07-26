local M = { gh('axelvc/template-string.nvim') }

M.event = 'InsertEnter'

M.ft = {
  'cs',
  'html',
  'javascript',
  'javascriptreact',
  'python',
  'svelte',
  'typescript',
  'typescriptreact',
  'vue',
}

---@module 'template-string'
---@type table
M.opts = {
  remove_template_string = true,
}

return M
