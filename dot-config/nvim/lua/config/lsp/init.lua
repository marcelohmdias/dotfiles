-- LSP layer: enable list, base capabilities and setup.
-- Neovim 0.12 native LSP: configs in lsp/ dir, enabled via vim.lsp.enable().
-- This module must be require-safe (no side-effects); call setup() to activate.

local M = {}

-- Lint LSP config markers (mutually exclusive: oxlint > biome > eslint)
local lint_markers = {
  oxlint = { '.oxlintrc.json', '.oxlintrc.jsonc', 'oxlint.config.ts', 'oxlint.config.js' },
  biome = { 'biome.json', 'biome.jsonc' },
  eslint = {
    '.eslintrc',
    '.eslintrc.cjs',
    '.eslintrc.js',
    '.eslintrc.json',
    '.eslintrc.yaml',
    '.eslintrc.yml',
    'eslint.config.cjs',
    'eslint.config.js',
    'eslint.config.mjs',
    'eslint.config.ts',
    'eslint.config.mts',
    'eslint.config.cts',
  },
}

--- Default set of always-enabled servers.
local always_on = {
  'astro',
  'bashls',
  'css_variables',
  'cssls',
  'dartls',
  'denols',
  'emmet_language_server',
  'fish_lsp',
  'gopls',
  'graphql',
  'harper_ls',
  'html',
  'jdtls',
  'jsonls',
  'just',
  'lemminx',
  'lua_ls',
  'marksman',
  'prismals',
  'sqls',
  'tailwindcss',
  'taplo',
  'unocss',
  'vue_ls',
  'yamlls',
}

--- Add a server to the resolved list only if its binary is executable.
---@param server string
---@param servers string[]
---@param skipped string[]
---@param is_executable fun(cmd: string): boolean
local function add_if_executable(server, servers, skipped, is_executable)
  if is_executable(server) then
    table.insert(servers, server)
  else
    table.insert(skipped, server)
  end
end

--- Resolve the TypeScript server (tsc) when the feature flag is on.
---@param flags { tsc_enabled: boolean }
---@param servers string[]
---@param skipped string[]
---@param is_executable fun(cmd: string): boolean
local function resolve_ts_server(flags, servers, skipped, is_executable)
  if not flags.tsc_enabled then
    return
  end
  add_if_executable('tsc', servers, skipped, is_executable)
end

--- Resolve vtsls (always enabled; restricted to vue/astro when tsc is primary).
---@param servers string[]
local function resolve_vtsls(servers)
  table.insert(servers, 'vtsls')
end

--- Resolve Docker servers if the feature flag is on.
---@param flags { docker_enabled: boolean }
---@param servers string[]
---@param skipped string[]
---@param is_executable fun(cmd: string): boolean
local function resolve_docker_servers(flags, servers, skipped, is_executable)
  if not flags.docker_enabled then
    return
  end
  add_if_executable('dockerls', servers, skipped, is_executable)
  add_if_executable('docker_compose_language_service', servers, skipped, is_executable)
end

--- Resolve Copilot if the feature flag is on.
---@param flags { copilot_enabled: boolean }
---@param servers string[]
---@param skipped string[]
---@param is_executable fun(cmd: string): boolean
local function resolve_copilot(flags, servers, skipped, is_executable)
  if not flags.copilot_enabled then
    return
  end
  add_if_executable('copilot', servers, skipped, is_executable)
end

--- Resolve the exclusive lint server (oxlint > biome > eslint).
---@param markers fun(list: string[]): boolean
---@param servers string[]
---@param skipped string[]
---@param is_executable fun(cmd: string): boolean
local function resolve_lint_server(markers, servers, skipped, is_executable)
  if markers(lint_markers.oxlint) then
    add_if_executable('oxlint', servers, skipped, is_executable)
  elseif markers(lint_markers.biome) then
    add_if_executable('biome', servers, skipped, is_executable)
  elseif markers(lint_markers.eslint) then
    add_if_executable('eslint', servers, skipped, is_executable)
  end
end

--- Resolve which LSP servers should be enabled for the current project.
-- Pure function: injectable flags, marker predicate and executable predicate.
---@param flags { tsc_enabled: boolean, docker_enabled: boolean, copilot_enabled: boolean }
---@param markers fun(list: string[]): boolean
---@param is_executable? fun(cmd: string): boolean
---@return { servers: string[], skipped: string[] }
function M._resolve_servers(flags, markers, is_executable)
  is_executable = is_executable or function(_)
    return true
  end

  local servers = {}
  local skipped = {}

  for _, name in ipairs(always_on) do
    add_if_executable(name, servers, skipped, is_executable)
  end

  resolve_ts_server(flags, servers, skipped, is_executable)
  resolve_vtsls(servers)
  resolve_docker_servers(flags, servers, skipped, is_executable)
  resolve_copilot(flags, servers, skipped, is_executable)
  resolve_lint_server(markers, servers, skipped, is_executable)

  return { servers = servers, skipped = skipped }
end

--- Base capabilities declared before enabling servers.
-- Workspace fileOperations unlock Rename File (`<leader>cR`).
-- Completion-engine capabilities are intentionally NOT injected here.
---@return table|nil
function M._base_capabilities()
  return {
    workspace = {
      fileOperations = {
        didRename = true,
        willRename = true,
      },
    },
  }
end

--- Load a server config table from runtimepath/lsp/<server>.lua.
-- The lsp/ directory is not under lua/, so it is not reachable via require().
---@param server string
---@return table|nil
function M._load_server_config(server)
  local path = vim.api.nvim_get_runtime_file('lsp/' .. server .. '.lua', false)[1]
  if not path then
    return nil
  end
  local ok, cfg = pcall(loadfile(path))
  if ok and type(cfg) == 'table' then
    return cfg
  end
  return nil
end

--- Return the executable name for a server by reading its config cmd.
---@param server string
---@return string
function M._server_cmd(server)
  local cfg = M._load_server_config(server)
  if cfg and type(cfg.cmd) == 'table' and type(cfg.cmd[1]) == 'string' then
    return cfg.cmd[1]
  end
  return server
end

--- Ensure Mason's bin directory is on PATH so installed servers are found.
-- Mason.setup() normally does this, but the LSP layer may boot first.
function M._ensure_mason_path()
  local mason_bin = vim.fn.stdpath('data') .. '/mason/bin'
  if vim.env.PATH:find(mason_bin, 1, true) then
    return
  end
  local sep = package.config:sub(1, 1) == '\\' and ';' or ':'
  vim.env.PATH = mason_bin .. sep .. vim.env.PATH
end

--- Default executable predicate used by setup().
---@param server string
---@return boolean
function M._is_executable(server)
  return vim.fn.executable(M._server_cmd(server)) == 1
end

--- Apply base workspace capabilities to all LSP clients.
local function apply_base_capabilities()
  local caps = M._base_capabilities()
  if caps then
    vim.lsp.config('*', { capabilities = caps })
  end
end

--- Read feature flags from vim.g.*.
---@return { tsc_enabled: boolean, docker_enabled: boolean, copilot_enabled: boolean }
local function read_flags()
  return {
    tsc_enabled = vim.g.tsc_enabled,
    docker_enabled = vim.g.docker_enabled,
    copilot_enabled = vim.g.copilot_enabled,
  }
end

--- Resolve servers for the current project using default predicates.
---@return { servers: string[], skipped: string[] }
local function resolve_with_defaults()
  local flags = read_flags()
  return M._resolve_servers(flags, function(markers)
    return vim.fs.root(0, markers) ~= nil
  end, M._is_executable)
end

--- Notify about servers that cannot run because their binary is missing.
---@param skipped string[]
local function notify_skipped(skipped)
  if #skipped > 0 then
    vim.notify('[MiniPack] LSP servers skipped (not executable): ' .. table.concat(skipped, ', '), vim.log.levels.WARN)
  end
end

--- Register server configs eagerly to avoid FileType race conditions.
---@param servers string[]
local function register_server_configs(servers)
  for _, server in ipairs(servers) do
    local cfg = M._load_server_config(server)
    if cfg and type(cfg) == 'table' then
      vim.lsp.config(server, cfg)
    end
  end
end

--- Enable servers now and re-trigger after VimEnter for CLI-opened buffers.
---@param servers string[]
local function enable_servers(servers)
  vim.lsp.enable(servers)
  vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    group = vim.api.nvim_create_augroup('minipack_lsp_enable', { clear = true }),
    callback = function()
      vim.lsp.enable(servers)
    end,
  })
end

--- Activate the LSP layer.
function M.setup()
  M._ensure_mason_path()
  apply_base_capabilities()

  local result = resolve_with_defaults()
  notify_skipped(result.skipped)
  register_server_configs(result.servers)
  enable_servers(result.servers)

  -- Register LspAttach keymaps and LSP-pure handlers.
  require('config.lsp.keymaps').setup()
  require('config.lsp.handlers').setup()
end

return M
