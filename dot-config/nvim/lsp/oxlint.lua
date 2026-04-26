---@type vim.lsp.Config
return {
  cmd = { 'oxc_language_server' },
  filetypes = {
    'astro',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'vue',
  },
  root_markers = { '.oxlintrc.json', '.oxlintrc.jsonc', 'oxlint.config.ts', 'oxlint.config.js' },
  workspace_required = true,
}
