---@type vim.lsp.Config
return {
  cmd = { 'harper-ls', '--stdio' },
  filetypes = {
    'gitcommit',
    'markdown',
    'text',
  },
  root_markers = { '.git' },
  settings = {
    ['harper-ls'] = {
      linters = {
        sentence_capitalization = false,
        spell_check = true,
      },
    },
  },
}
