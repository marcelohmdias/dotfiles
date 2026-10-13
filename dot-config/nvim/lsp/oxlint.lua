---@type vim.lsp.Config
return {
  cmd = { 'oxlint', '--lsp' },
  filetypes = {
    'astro',
    'javascript',
    'javascriptreact',
    'svelte',
    'typescript',
    'typescriptreact',
    'vue',
  },
  root_markers = { '.oxlintrc.json', '.oxlintrc.jsonc', 'oxlint.config.ts', 'oxlint.config.js' },
  init_options = {
    fixKind = { 'safe', 'unsafe' },
  },
  workspace_required = true,
}
