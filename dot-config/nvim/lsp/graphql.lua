---@type vim.lsp.Config
return {
  cmd = { 'graphql-lsp', 'server', '-m', 'stream' },
  filetypes = { 'graphql', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = {
    '.graphqlrc',
    '.graphqlrc.json',
    '.graphqlrc.yaml',
    '.graphqlrc.yml',
    '.graphqlrc.ts',
    '.graphqlrc.js',
    'graphql.config.json',
    'graphql.config.yaml',
    'graphql.config.yml',
    'graphql.config.ts',
    'graphql.config.js',
  },
  workspace_required = true,
}
