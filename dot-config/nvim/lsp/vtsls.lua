local core = require('core.lsp')

-- When tsc is primary, vtsls only handles vue and astro (hybrid mode TS delegation).
local filetypes = vim.g.tsc_enabled and { 'vue', 'astro' }
  or {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'vue',
    'astro',
  }

--- Resolve a Mason/MiniPack package path to a node_modules subfolder.
---@param pkg_name string mason package name (e.g. "vue-language-server")
---@param suffix string subpath inside node_modules (e.g. "/node_modules/@vue/language-server")
---@return string
local function plugin_path(pkg_name, suffix)
  local ok, registry = pcall(require, 'mason-registry')
  if ok then
    local ok_pkg, pkg = pcall(registry.get_package, registry, pkg_name)
    if ok_pkg and pkg then
      local path = pkg:get_install_path() .. suffix
      if vim.uv.fs_stat(path) then
        return path
      end
    end
  end

  local fallback = vim.fn.stdpath('data') .. '/site/pack/core/opt/' .. pkg_name .. suffix
  return vim.uv.fs_stat(fallback) and fallback or ''
end

--- Resolve the @vue/typescript-plugin location.
---@return string
local function vue_plugin_path()
  return plugin_path('vue-language-server', '/node_modules/@vue/language-server')
end

--- Resolve the @astrojs/ts-plugin location.
---@return string
local function astro_plugin_path()
  return plugin_path('astro-language-server', '/node_modules/@astrojs/ts-plugin')
end

--- Build the vtsls tsserver globalPlugins list, omitting plugins that cannot be resolved.
---@return table[]
local function global_plugins()
  local plugins = {}

  local vue_path = vue_plugin_path()
  if vue_path ~= '' then
    table.insert(plugins, {
      name = '@vue/typescript-plugin',
      location = vue_path,
      languages = { 'vue' },
      configNamespace = 'typescript',
      enableForWorkspaceTypeScriptVersions = true,
    })
  end

  local astro_path = astro_plugin_path()
  if astro_path ~= '' then
    table.insert(plugins, {
      name = '@astrojs/ts-plugin',
      location = astro_path,
      enableForWorkspaceTypeScriptVersions = true,
    })
  end

  return plugins
end

---@type vim.lsp.Config
return {
  cmd = { 'vtsls', '--stdio' },
  filetypes = filetypes,
  root_dir = function(bufnr, on_dir)
    core.ts_root_by_lockfile(bufnr, on_dir)
  end,
  init_options = { hostInfo = 'neovim' },
  settings = {
    complete_function_calls = true,
    typescript = {
      updateImportsOnFileMove = { enabled = 'always' },
      suggest = {
        completeFunctionCalls = true,
      },
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = 'literals' },
        parameterTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = false },
      },
    },
    javascript = {
      updateImportsOnFileMove = { enabled = 'always' },
      suggest = {
        completeFunctionCalls = true,
      },
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = 'literals' },
        parameterTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = false },
      },
    },
    vtsls = {
      enableMoveToFileCodeAction = true,
      autoUseWorkspaceTsdk = true,
      experimental = {
        maxInlayHintLength = 30,
        completion = {
          enableServerSideFuzzyMatch = true,
        },
      },
      tsserver = {
        globalPlugins = global_plugins(),
      },
    },
  },
  workspace_required = true,
}
