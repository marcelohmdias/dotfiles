--- Shared utilities for LSP server configs.
local M = {}

--- Lockfile markers used to identify the workspace root in monorepos.
local lockfile_markers = { 'bun.lockb', 'yarn.lock', 'pnpm-lock.yaml', 'package-lock.json' }

--- Fallback config markers when no lockfile is found.
local config_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json' }

--- Deno project markers used by the Deno guard.
local deno_markers = { 'deno.json', 'deno.jsonc', 'deno.lock' }

--- Check whether any of the given markers exists directly in `dir`.
---@param dir string
---@param markers string[]
---@return boolean
local function has_marker(dir, markers)
  for _, marker in ipairs(markers) do
    if vim.uv.fs_stat(dir .. '/' .. marker) then
      return true
    end
  end
  return false
end

--- Resolve the TypeScript project root and run a Deno guard.
-- Prefers the nearest lockfile (monorepo root) and falls back to the nearest
-- package.json / tsconfig.json. Aborts when a Deno marker is at or below the
-- TS root, or when the closest Deno marker is closer than the TS root.
-- Calls `on_dir(root)` when a root is found (matches vim.lsp.Config root_dir signature).
---@param bufnr number
---@param on_dir? fun(root: string)
---@return string|nil root_dir
function M.ts_root_by_lockfile(bufnr, on_dir)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then
    return nil
  end

  local dir = vim.fs.dirname(path)
  local root = nil

  -- Monorepo: stop at the first lockfile found while walking up (include dir itself).
  local current = dir
  while current do
    if has_marker(current, lockfile_markers) then
      root = current
      break
    end
    local parent = vim.fs.dirname(current)
    if parent == current then
      break
    end
    current = parent
  end

  -- No lockfile: fall back to the nearest config marker.
  if not root then
    root = vim.fs.root(path, config_markers)
  end

  if not root then
    return nil
  end

  local deno_root = vim.fs.root(path, deno_markers)
  if deno_root then
    if #deno_root > #root then
      return nil
    end
    if #deno_root == #root and deno_root == root then
      return nil
    end
  end

  if on_dir then
    on_dir(root)
  end
  return root
end

--- Find a TypeScript compiler binary for `root` with major version >= 7.
-- Checks node_modules/.bin first (tsc, then tsgo), then PATH (tsc, then tsgo).
-- Results are cached per root. Probes are injectable for hermetic tests.
---@param root? string
---@param probes? { executable?: fun(cmd: string): boolean, run_version?: fun(cmd: string): integer|nil }
---@return string|nil
function M.find_tsc_bin(root, probes)
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

  M._tsc_cache = M._tsc_cache or {}
  if M._tsc_cache[root] ~= nil then
    return M._tsc_cache[root]
  end

  local candidates = {}
  if root then
    table.insert(candidates, root .. '/node_modules/.bin/tsc')
    table.insert(candidates, root .. '/node_modules/.bin/tsgo')
  end
  table.insert(candidates, 'tsc')
  table.insert(candidates, 'tsgo')

  for _, cmd in ipairs(candidates) do
    if executable(cmd) then
      local major = run_version(cmd)
      if major and major >= 7 then
        M._tsc_cache[root] = cmd
        return cmd
      end
    end
  end

  M._tsc_cache[root] = nil
  return nil
end

return M
