---@type vim.lsp.Config
return {
  cmd = { 'vue-language-server', '--stdio' },
  filetypes = { 'vue' },
  init_options = {
    vue = {
      hybridMode = true,
    },
  },
  root_markers = { 'package.json', '.git' },
}
