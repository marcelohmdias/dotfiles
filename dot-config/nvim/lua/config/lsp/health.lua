-- LSP layer health check.
-- This module must be require-safe (no side-effects); call check() to run :checkhealth.

local M = {}

--- Map server names to their Mason package names.
---@type table<string, string>
M._mason_package_map = {
  astro = 'astro-language-server',
  bashls = 'bash-language-server',
  biome = 'biome',
  copilot = 'copilot-language-server',
  cssls = 'css-lsp',
  css_variables = 'css-variables-language-server',
  dartls = nil, -- system dependency
  denols = nil, -- system dependency
  dockerls = 'dockerfile-language-server',
  docker_compose_language_service = 'docker-compose-language-service',
  emmet_language_server = 'emmet-language-server',
  eslint = 'eslint-lsp',
  fish_lsp = 'fish-lsp',
  gopls = 'gopls',
  graphql = 'graphql-language-service-cli',
  harper_ls = 'harper-ls',
  html = 'html-lsp',
  jdtls = 'jdtls',
  jsonls = 'json-lsp',
  just = 'just-lsp',
  lemminx = 'lemminx',
  lua_ls = 'lua-language-server',
  marksman = 'marksman',
  oxlint = 'oxlint',
  prismals = 'prisma-language-server',
  sqls = 'sqls',
  tailwindcss = 'tailwindcss-language-server',
  taplo = 'taplo',
  tsc = 'tsc',
  unocss = 'unocss-language-server',
  vtsls = 'vtsls',
  vue_ls = 'vue-language-server',
  yamlls = 'yaml-language-server',
}

--- Read Mason's ensure_installed list from mason-tool-installer opts.
-- Returns an empty set if the spec is unavailable (no network/Mason).
---@return table<string, boolean>
function M._mason_set()
  local ok, spec = pcall(require, 'plugins.config.mason_tool_installer')
  local set = {}
  if ok and spec and type(spec.opts) == 'table' and type(spec.opts.ensure_installed) == 'table' then
    for _, pkg in ipairs(spec.opts.ensure_installed) do
      set[pkg] = true
    end
  end
  return set
end

--- Detect the TypeScript compiler version (major) if tsc is available.
-- Probes are injectable for testing.
---@param probes? { executable?: fun(cmd: string): boolean, run_version?: fun(cmd: string): integer|nil }
---@return string|nil
function M._ts_version(probes)
  probes = probes or {}
  local executable = probes.executable or function(cmd)
    return vim.fn.executable(cmd) == 1
  end
  local run_version = probes.run_version
    or function(cmd)
      local out = vim.fn.system(cmd .. ' --version')
      local major_str = out:match('(%d+)')
      return major_str and tonumber(major_str) or nil
    end
  if not executable('tsc') then
    return nil
  end
  local major = run_version('tsc')
  return major and tostring(major) or nil
end

--- Build the health report as plain data.
---@param servers string[] enabled server names
---@param is_executable fun(cmd: string): boolean
---@param mason_set table<string, boolean>
---@param ts_version string|nil
---@return { rows: { server: string, cmd: string, executable: boolean, mason: boolean }[], ts_version: string|nil, capabilities_base: boolean }
function M._report(servers, is_executable, mason_set, ts_version)
  local rows = {}
  for _, server in ipairs(servers) do
    local cmd = require('config.lsp.init')._server_cmd(server)
    local pkg = M._mason_package_map[server]
    table.insert(rows, {
      server = server,
      cmd = cmd,
      executable = is_executable(cmd),
      mason = pkg ~= nil and mason_set[pkg] == true,
    })
  end
  return {
    rows = rows,
    ts_version = ts_version,
    capabilities_base = true,
  }
end

--- Resolve the enabled server list using the production resolver.
---@return { servers: string[], skipped: string[] }
local function resolve_enabled()
  local init = require('config.lsp.init')
  local flags = {
    tsc_enabled = vim.g.tsc_enabled,
    docker_enabled = vim.g.docker_enabled,
    copilot_enabled = vim.g.copilot_enabled,
  }
  return init._resolve_servers(flags, function(markers)
    return vim.fs.root(0, markers) ~= nil
  end, init._is_executable)
end

--- Build the report for the current project.
---@return { servers: string[], skipped: string[] }, table
local function build_report()
  local result = resolve_enabled()
  local init = require('config.lsp.init')
  local mason_set = M._mason_set()
  local report = M._report(result.servers, init._is_executable, mason_set, M._ts_version())
  return result, report
end

--- Render the TS-version section.
---@param ts_version string|nil
local function render_ts_version(ts_version)
  if ts_version then
    vim.health.ok('TypeScript compiler major version: ' .. ts_version)
  else
    vim.health.warn('TypeScript compiler (tsc) not found on PATH')
  end
end

--- Render the executable/missing summary.
---@param rows { server: string, cmd: string, executable: boolean, mason: boolean }[]
local function render_executable_summary(rows)
  local missing = {}
  for _, row in ipairs(rows) do
    if not row.executable then
      table.insert(missing, row.server .. ' (' .. row.cmd .. ')')
    end
  end
  if #missing > 0 then
    vim.health.warn('Servers not executable: ' .. table.concat(missing, ', '))
  else
    vim.health.ok('All enabled servers have an executable')
  end
end

--- Render the per-server table.
---@param rows { server: string, cmd: string, executable: boolean, mason: boolean }[]
local function render_server_table(rows)
  vim.health.start('Enabled servers')
  for _, row in ipairs(rows) do
    local status = row.executable and 'OK' or 'MISSING'
    local coverage = row.mason and 'Mason' or 'system'
    vim.health.info(string.format('%-32s [%s] %s', row.server, status, coverage))
  end
end

--- Run :checkhealth for the LSP layer.
function M.check()
  local _, report = build_report()

  vim.health.start('LSP layer')
  vim.health.ok('Base capabilities (workspace fileOperations) declared')

  render_ts_version(report.ts_version)
  render_executable_summary(report.rows)
  render_server_table(report.rows)
end

return M
