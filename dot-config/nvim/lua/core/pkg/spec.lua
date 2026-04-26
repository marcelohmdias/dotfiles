local M = {}

local KNOWN_FIELDS = {
  build = true,
  checkout = true,
  cmd = true,
  config = true,
  dependencies = true,
  enabled = true,
  event = true,
  ft = true,
  import = true,
  init = true,
  keys = true,
  lazy = true,
  name = true,
  opts = true,
  src = true,
  version = true,
}

--- Normalize src field: copy [1] to src.
--- URLs are expected to be already resolved via gh()/cb() globals.
---@param spec table
local function normalize_src(spec)
  if spec[1] and not spec.src then
    spec.src = spec[1]
    spec[1] = nil
  end
end

--- Derive name from src (last path segment, strip .git).
---@param spec table
local function normalize_name(spec)
  if spec.name then return end
  if not spec.src then return end
  local name = spec.src:match('/([^/]+)%.git$') or spec.src:match('/([^/]+)$')
  spec.name = name
end

--- Normalize lazy field (default true).
---@param spec table
local function normalize_lazy(spec)
  if spec.lazy == nil then
    spec.lazy = true
  end
end

--- Resolve enabled field (call if function).
---@param spec table
local function normalize_enabled(spec)
  if type(spec.enabled) == 'function' then
    spec.enabled = spec.enabled()
  end
  if spec.enabled == nil then
    spec.enabled = true
  end
end

--- Normalize string fields to arrays.
---@param spec table
---@param field string
local function to_array(spec, field)
  if type(spec[field]) == 'string' then
    spec[field] = { spec[field] }
  end
end

--- Normalize dependencies: accept strings or tables with name.
--- Each entry becomes { src = url, name = name }.
---@param spec table
local function normalize_dependencies(spec)
  if not spec.dependencies then return end
  local deps = type(spec.dependencies) == 'string' and { spec.dependencies } or spec.dependencies
  local normalized = {}
  for _, dep in ipairs(deps) do
    if type(dep) == 'string' then
      local name = dep:match('/([^/]+)%.git$') or dep:match('/([^/]+)$')
      normalized[#normalized + 1] = { src = dep, name = name }
    elseif type(dep) == 'table' then
      local src = dep[1] or dep.src
      local name = dep.name or (src and (src:match('/([^/]+)%.git$') or src:match('/([^/]+)$')))
      if src then
        normalized[#normalized + 1] = { src = src, name = name }
      end
    end
  end
  spec.dependencies = normalized
end

--- Warn on unknown fields.
---@param spec table
local function warn_unknown_fields(spec)
  for key, _ in pairs(spec) do
    if type(key) == 'string' and not KNOWN_FIELDS[key] then
      vim.notify('[MiniPack] Unknown field "' .. key .. '" in spec ' .. (spec.name or '?'), vim.log.levels.WARN)
    end
  end
end

local CUSTOM_EVENTS = { VeryLazy = true, LazyFile = true }

--- Expand custom events (VeryLazy, LazyFile) to 'User X' pattern.
---@param spec table
local function normalize_events(spec)
  if not spec.event then return end
  for i, event in ipairs(spec.event) do
    if CUSTOM_EVENTS[event] then
      spec.event[i] = 'User ' .. event
    end
  end
end

--- Convert ft field to FileType events.
---@param spec table
local function normalize_ft(spec)
  if not spec.ft then return end
  local fts = type(spec.ft) == 'string' and { spec.ft } or spec.ft
  spec.event = spec.event or {}
  for _, ft in ipairs(fts) do
    spec.event[#spec.event + 1] = 'FileType ' .. ft
  end
end

--- Normalize a single spec in-place.
---@param spec table
function M.normalize(spec)
  normalize_src(spec)
  normalize_name(spec)
  normalize_lazy(spec)
  normalize_enabled(spec)
  to_array(spec, 'event')
  to_array(spec, 'cmd')
  normalize_dependencies(spec)
  normalize_ft(spec)
  normalize_events(spec)
end

--- Validate a spec. Returns true if valid.
---@param spec table
---@return boolean
function M.validate(spec)
  -- Import-only entries are valid without src
  if spec.import then return true end

  -- No-src config specs are valid (foundation plugins)
  if not spec.src and (spec.config or spec.opts) then return true end

  if not spec.src then
    vim.notify('[MiniPack] Spec missing "src": ' .. vim.inspect(spec), vim.log.levels.WARN)
    return false
  end

  if not spec.name then
    vim.notify('[MiniPack] Could not derive name from src: ' .. spec.src, vim.log.levels.WARN)
    return false
  end

  warn_unknown_fields(spec)
  return true
end

--- Resolve opts (table or function).
---@param spec table
---@return table
function M.resolve_opts(spec)
  if type(spec.opts) == 'function' then
    return spec.opts() or {}
  end
  return spec.opts or {}
end

--- Run config for a spec (after plugin is loaded).
---@param spec table
function M.run_config(spec)
  local opts = M.resolve_opts(spec)

  if type(spec.config) == 'function' then
    spec.config(spec, opts)
  elseif spec.config == true or (spec.opts and spec.config == nil) then
    -- Strip common suffixes (.nvim, .lua, nvim-) for require path
    local mod_name = spec.name:gsub('%.nvim$', ''):gsub('%.lua$', ''):gsub('^nvim%-', '')
    local ok, mod = pcall(require, mod_name)
    if ok and mod.setup then
      mod.setup(opts)
    elseif not ok then
      vim.notify('[MiniPack] Failed to require "' .. mod_name .. '": ' .. mod, vim.log.levels.WARN)
    end
  end
end

--- List fields that are concatenated (not overwritten) during merge.
local LIST_FIELDS = { 'cmd', 'dependencies', 'event', 'keys' }

--- Merge a secondary spec into a primary spec (in-place).
--- opts: deep-merged. List fields (keys, event, cmd, dependencies): concatenated.
--- Scalar fields (src, name, config, init, build, lazy): primary wins.
---@param primary table The main spec (mutated)
---@param secondary table The spec to merge in
function M.merge(primary, secondary)
  -- Deep-merge opts
  if secondary.opts then
    if type(primary.opts) == 'function' or type(secondary.opts) == 'function' then
      local orig_primary_opts = primary.opts
      local orig_secondary_opts = secondary.opts
      primary.opts = function()
        local a = type(orig_primary_opts) == 'function' and orig_primary_opts() or orig_primary_opts or {}
        local b = type(orig_secondary_opts) == 'function' and orig_secondary_opts() or orig_secondary_opts or {}
        return vim.tbl_deep_extend('force', a, b)
      end
    else
      primary.opts = vim.tbl_deep_extend('force', primary.opts or {}, secondary.opts)
    end
  end

  -- Concatenate list fields
  for _, field in ipairs(LIST_FIELDS) do
    if secondary[field] then
      primary[field] = primary[field] or {}
      vim.list_extend(primary[field], secondary[field])
    end
  end
end

return M
