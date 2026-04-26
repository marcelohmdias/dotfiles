local M = {}

local spec_mod = require('core.pkg.spec')

--- Map a Lua module path to a filesystem path.
--- Returns (filepath, is_dir) or (nil, nil) if not found.
---@param import_path string e.g. 'plugins' or 'plugins.config.treesitter'
---@return string?, boolean?
local function resolve_path(import_path)
  local rel = import_path:gsub('%.', '/')
  local base = vim.fn.stdpath('config') .. '/lua/' .. rel

  -- Check file first
  local file = base .. '.lua'
  if vim.uv.fs_stat(file) then
    return file, false
  end

  -- Check directory
  if vim.uv.fs_stat(base) then
    return base, true
  end

  return nil, nil
end

--- Scan a directory for top-level .lua files (alphabetical).
--- Returns list of module paths.
---@param dir string Absolute directory path
---@param import_path string Module path prefix
---@return string[]
local function scan_dir(dir, import_path)
  local modules = {} ---@type string[]
  local handle = vim.uv.fs_scandir(dir)
  if not handle then return modules end

  while true do
    local name, ftype = vim.uv.fs_scandir_next(handle)
    if not name then break end
    if ftype == 'file' and name:match('%.lua$') then
      local mod_name = name:gsub('%.lua$', '')
      modules[#modules + 1] = import_path .. '.' .. mod_name
    end
  end

  table.sort(modules)
  return modules
end

--- Resolve an import path recursively, collecting all specs.
---@param import_path string Module path to resolve
---@param _seen? table<string, boolean> Cycle detection set (internal)
---@return table[] specs Flat list of normalized specs
function M.resolve(import_path, _seen)
  _seen = _seen or {}
  if _seen[import_path] then
    vim.notify('[MiniPack] Circular import detected: ' .. import_path, vim.log.levels.WARN)
    return {}
  end
  _seen[import_path] = true

  local path, is_dir = resolve_path(import_path)
  if not path then
    vim.notify('[MiniPack] Import not found: ' .. import_path, vim.log.levels.WARN)
    return {}
  end

  local modules = {}
  if is_dir then
    modules = scan_dir(path, import_path)
  else
    modules = { import_path }
  end

  local specs = {} ---@type table[]

  for _, mod_path in ipairs(modules) do
    local ok, result = pcall(require, mod_path)
    if not ok then
      vim.notify('[MiniPack] Failed to require "' .. mod_path .. '": ' .. result, vim.log.levels.WARN)
    elseif type(result) == 'table' then
      -- Detect single spec vs list: single spec has [1] as string (src URL)
      local items = (type(result[1]) == 'string' or result.src) and { result } or result
      for _, item in ipairs(items) do
        if item.import then
          -- Recurse into import chain
          local sub_specs = M.resolve(item.import, _seen)
          vim.list_extend(specs, sub_specs)
        else
          -- Normalize and collect spec
          spec_mod.normalize(item)
          if spec_mod.validate(item) and item.enabled then
            specs[#specs + 1] = item
          end
        end
      end
    end
  end

  return specs
end

return M
