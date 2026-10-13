---@type vim.lsp.Config
return {
  cmd = { 'emmet-language-server', '--stdio' },
  filetypes = {
    'astro',
    'css',
    'eruby',
    'html',
    'htmldjango',
    'javascript',
    'javascriptreact',
    'less',
    'pug',
    'sass',
    'scss',
    'typescriptreact',
    'vue',
  },
  root_markers = { '.git' },
}
