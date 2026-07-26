local ts_root_dir = require('core.lsp').ts_root_dir

-- When tsgo is primary, vtsls only handles vue (hybrid mode TS delegation)
local filetypes = vim.g.tsgo_enabled and { 'vue' }
  or { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' }

---@type vim.lsp.Config
return {
  cmd = { 'vtsls', '--stdio' },
  filetypes = filetypes,
  root_dir = function(bufnr, on_dir)
    local root = ts_root_dir(bufnr)
    if root then on_dir(root) end
  end,
  init_options = { hostInfo = 'neovim' },
  settings = {
    typescript = {
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = 'literals' },
        parameterTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = false },
      },
      updateImportsOnFileMove = { enabled = 'always' },
    },
    javascript = {
      updateImportsOnFileMove = { enabled = 'always' },
    },
    vtsls = {
      enableMoveToFileCodeAction = true,
      tsserver = {
        globalPlugins = {
          {
            name = '@vue/typescript-plugin',
            location = (function()
              local vue_ls_path = vim.fn.stdpath('data') .. '/site/pack/core/opt/vue-language-server'
              local plugin_path = vue_ls_path .. '/node_modules/@vue/language-server'
              if vim.uv.fs_stat(plugin_path) then return plugin_path end
              return ''
            end)(),
            languages = { 'vue' },
            configNamespace = 'typescript',
            enableForWorkspaceTypeScriptVersions = true,
          },
        },
      },
    },
  },
  workspace_required = true,
}
