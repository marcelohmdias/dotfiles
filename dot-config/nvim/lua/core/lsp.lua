--- Shared utilities for LSP server configs.
local M = {}

--- Check if the closest root is a Deno project (deno markers closer than package.json).
--- Used by tsgo and vtsls to avoid attaching in Deno projects.
---@param bufnr number
---@return string|nil root_dir
function M.ts_root_dir(bufnr)
  local deno_root = vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc', 'deno.lock' })
  local ts_root = vim.fs.root(bufnr, { 'tsconfig.json', 'jsconfig.json', 'package.json' })

  if deno_root and (not ts_root or #deno_root >= #ts_root) then
    return nil
  end

  return ts_root
end

return M
