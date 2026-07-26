---@type vim.lsp.Config
return {
  cmd = { 'emmet-language-server', '--stdio' },
  filetypes = {
    'astro',
    'css',
    'html',
    'javascriptreact',
    'less',
    'sass',
    'scss',
    'typescriptreact',
    'vue',
  },
  root_markers = { '.git' },
}
