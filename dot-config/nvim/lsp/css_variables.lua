---@type vim.lsp.Config
return {
  cmd = { 'css-variables-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  root_markers = { 'package.json', '.git' },
  settings = {
    cssVariables = {
      blacklistFolders = {
        '**/.cache',
        '**/.git',
        '**/bower_components',
        '**/node_modules',
      },
      lookupFiles = {
        '**/*.css',
        '**/*.scss',
        '**/*.less',
      },
    },
  },
}
