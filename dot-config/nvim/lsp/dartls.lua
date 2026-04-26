---@type vim.lsp.Config
return {
  cmd = { 'dart', 'language-server', '--protocol=lsp' },
  filetypes = { 'dart' },
  init_options = {
    closingLabels = true,
    flutterOutline = true,
    outline = true,
    suggestFromUnimportedLibraries = true,
  },
  root_markers = { 'pubspec.yaml', '.dart_tool', '.git' },
  settings = {
    dart = {
      analysisExcludedFolders = {
        vim.fn.expand('$HOME/.pub-cache'),
        vim.fn.expand('$HOME/fvm'),
      },
      completeFunctionCalls = true,
      showTodos = true,
      updateImportsOnRename = true,
    },
  },
}
