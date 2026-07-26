---@type vim.lsp.Config
return {
  cmd = { 'biome', 'lsp-proxy' },
  filetypes = {
    'astro',
    'css',
    'graphql',
    'javascript',
    'javascriptreact',
    'json',
    'jsonc',
    'svelte',
    'typescript',
    'typescriptreact',
    'vue',
  },
  root_markers = { 'biome.json', 'biome.jsonc' },
  workspace_required = true,
}
