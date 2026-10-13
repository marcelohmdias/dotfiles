---@type vim.lsp.Config
return {
  cmd = { 'unocss-language-server', '--stdio' },
  filetypes = {
    'astro',
    'css',
    'html',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'svelte',
    'vue',
  },
  root_markers = { 'package.json', '.git' },
  workspace_required = true,
}
