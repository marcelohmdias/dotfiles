local M = { gh('dmmulroy/ts-error-translator.nvim') }

M.ft = { 'astro', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' }

function M.config(_, opts)
  require('ts-error-translator').setup(opts)
end

---@type table
M.opts = {
  servers = { 'astro', 'tsgo', 'vue_ls', 'vtsls' },
}

return M
