---@type vim.lsp.Config
return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', '.git' },
  settings = {
    Lua = {
      codeLens = { enable = true },
      completion = { callSnippet = 'Replace' },
      doc = { privateName = { '^_' } },
      hint = {
        enable = true,
        arrayIndex = 'Disable',
        paramName = 'Disable',
        paramType = true,
        semicolon = 'Disable',
        setType = false,
      },
      workspace = {
        checkThirdParty = false,
      },
    },
  },
}
