local M = {}

--- Status column delegating to snacks.statuscolumn.
--- Used as `v:lua.MiniPack.statuscolumn()` in opt.statuscolumn.
---@return string
local _sc
function M.statuscolumn()
  if _sc == nil then
    _sc = package.loaded.snacks and require('snacks.statuscolumn') or false
  end
  return _sc and _sc.get() or ''
end

--- Format expression delegating to conform or LSP.
--- Used as `v:lua.MiniPack.formatexpr()` in opt.formatexpr.
---@return string|number
function M.formatexpr()
  local has_conform, conform = pcall(require, 'conform')
  if has_conform then
    return conform.formatexpr()
  end
  return vim.lsp.formatexpr({ timeout_ms = 3000 })
end

-- Root detection (based on LazyVim root.lua) ---------------------------------

---@type MiniPackRootSpec[]
M.root_spec = { 'lsp', { '.git', 'lua' }, 'cwd' }

---@type table<number, string>
local root_cache = {}

local detectors = {}

function detectors.cwd()
  return { vim.uv.cwd() }
end

function detectors.lsp(buf)
  local bufpath = M.root_bufpath(buf)
  if not bufpath then return {} end

  local roots = {} ---@type string[]
  local clients = vim.lsp.get_clients({ bufnr = buf })
  clients = vim.tbl_filter(function(client)
    return not vim.tbl_contains(vim.g.root_lsp_ignore or {}, client.name)
  end, clients)

  for _, client in pairs(clients) do
    for _, ws in pairs(client.config.workspace_folders or {}) do
      roots[#roots + 1] = vim.uri_to_fname(ws.uri)
    end
    if client.root_dir then
      roots[#roots + 1] = client.root_dir
    end
  end

  return vim.tbl_filter(function(path)
    path = M.root_realpath(path)
    return path and bufpath:find(path, 1, true) == 1
  end, roots)
end

---@param buf number
---@param patterns string[]|string
function detectors.pattern(buf, patterns)
  patterns = type(patterns) == 'string' and { patterns } or patterns
  local path = M.root_bufpath(buf) or vim.uv.cwd()
  local match = vim.fs.find(function(name)
    for _, p in ipairs(patterns) do
      if name == p then return true end
      if p:sub(1, 1) == '*' and name:find(vim.pesc(p:sub(2)) .. '$') then return true end
    end
    return false
  end, { path = path, upward = true })[1]
  return match and { vim.fs.dirname(match) } or {}
end

--- Resolve real path, normalizing symlinks.
---@param path? string
---@return string?
function M.root_realpath(path)
  if not path or path == '' then return nil end
  path = vim.uv.fs_realpath(path) or path
  return path:gsub('\\', '/')
end

--- Get real path of buffer.
---@param buf number
---@return string?
function M.root_bufpath(buf)
  return M.root_realpath(vim.api.nvim_buf_get_name(assert(buf)))
end

--- Resolve a root spec to a detector function.
---@param spec MiniPackRootSpec
---@return MiniPackRootFn
local function resolve(spec)
  if detectors[spec] then return detectors[spec] end
  if type(spec) == 'function' then return spec end
  return function(buf) return detectors.pattern(buf, spec) end
end

--- Detect root directories for buffer.
---@param opts? { buf?: number, spec?: MiniPackRootSpec[], all?: boolean }
---@return { spec: MiniPackRootSpec, paths: string[] }[]
local function detect(opts)
  opts = opts or {}
  opts.spec = opts.spec or type(vim.g.root_spec) == 'table' and vim.g.root_spec or M.root_spec
  opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf

  local ret = {} ---@type { spec: MiniPackRootSpec, paths: string[] }[]
  for _, spec in ipairs(opts.spec) do
    local paths = resolve(spec)(opts.buf) or {}
    paths = type(paths) == 'table' and paths or { paths }
    local roots = {} ---@type string[]
    for _, p in ipairs(paths) do
      local pp = M.root_realpath(p)
      if pp and not vim.tbl_contains(roots, pp) then
        roots[#roots + 1] = pp
      end
    end
    table.sort(roots, function(a, b) return #a > #b end)
    if #roots > 0 then
      ret[#ret + 1] = { spec = spec, paths = roots }
      if opts.all == false then break end
    end
  end
  return ret
end

--- Get the root directory for the current or given buffer.
--- Uses cache for performance. Falls back to cwd.
---@param opts? { buf?: number }
---@return string
function M.root(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  local ret = root_cache[buf]
  if not ret then
    local roots = detect({ all = false, buf = buf })
    ret = roots[1] and roots[1].paths[1] or vim.uv.cwd()
    root_cache[buf] = ret
  end
  return ret
end

--- Get the git root for the current buffer.
---@return string
function M.root_git()
  local root = M.root()
  local git_root = vim.fs.find('.git', { path = root, upward = true })[1]
  return git_root and vim.fn.fnamemodify(git_root, ':h') or root
end

--- Setup root cache invalidation autocmds.
function M.root_setup()
  vim.api.nvim_create_autocmd({ 'LspAttach', 'BufWritePost', 'DirChanged', 'BufEnter' }, {
    group = vim.api.nvim_create_augroup('MiniPack_root_cache', { clear = true }),
    callback = function(event) root_cache[event.buf] = nil end,
  })
end

-- Git conflict markers highlight -----------------------------------------------

local conflict_ns = vim.api.nvim_create_namespace('git_conflict')
local conflict_timer = vim.uv.new_timer()

local function conflict_get_hl()
  local C = require('catppuccin.palettes').get_palette()
  local base = C.base or '#1e1e2e'

  -- Blend foreground color with base at given alpha (0-100)
  local function blend(fg, alpha)
    local r1, g1, b1 = tonumber(fg:sub(2, 3), 16), tonumber(fg:sub(4, 5), 16), tonumber(fg:sub(6, 7), 16)
    local r2, g2, b2 = tonumber(base:sub(2, 3), 16), tonumber(base:sub(4, 5), 16), tonumber(base:sub(6, 7), 16)
    local a = alpha / 100
    return string.format(
      '#%02x%02x%02x',
      math.floor(r1 * a + r2 * (1 - a) + 0.5),
      math.floor(g1 * a + g2 * (1 - a) + 0.5),
      math.floor(b1 * a + b2 * (1 - a) + 0.5)
    )
  end

  return {
    current = blend(C.green, 20),
    current_label = blend(C.green, 35),
    incoming = blend(C.blue, 20),
    incoming_label = blend(C.blue, 35),
    ancestor = blend(C.mauve, 20),
    ancestor_label = blend(C.mauve, 35),
  }
end

function M.conflict_setup_hl()
  local hl = conflict_get_hl()
  vim.api.nvim_set_hl(0, 'GitConflictCurrent', { bg = hl.current })
  vim.api.nvim_set_hl(0, 'GitConflictCurrentLabel', { bg = hl.current_label })
  vim.api.nvim_set_hl(0, 'GitConflictIncoming', { bg = hl.incoming })
  vim.api.nvim_set_hl(0, 'GitConflictIncomingLabel', { bg = hl.incoming_label })
  vim.api.nvim_set_hl(0, 'GitConflictAncestor', { bg = hl.ancestor })
  vim.api.nvim_set_hl(0, 'GitConflictAncestorLabel', { bg = hl.ancestor_label })
end

--- Apply conflict highlights to a buffer.
--- Skips bigfiles (snacks) and buffers without conflict markers.
---@param buf number
function M.conflict_apply(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  if vim.b[buf].snacks_bigfile then return end

  -- Skip large files (same threshold as snacks.bigfile: 1.5MB)
  local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
  if ok and stats and stats.size > 1.5 * 1024 * 1024 then return end

  vim.api.nvim_buf_clear_namespace(buf, conflict_ns, 0, -1)

  -- Quick check without copying buffer to Lua
  local has_conflict = vim.api.nvim_buf_call(buf, function()
    return vim.fn.search('^<<<<<<<', 'nw') > 0
  end)
  if not has_conflict then return end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local region = nil -- 'current' | 'ancestor' | 'incoming'
  for i, line in ipairs(lines) do
    local lnum = i - 1
    if line:match('^<<<<<<<') then
      region = 'current'
      vim.api.nvim_buf_set_extmark(buf, conflict_ns, lnum, 0, { line_hl_group = 'GitConflictCurrentLabel', end_row = lnum + 1 })
    elseif line:match('^||||||') then
      region = 'ancestor'
      vim.api.nvim_buf_set_extmark(buf, conflict_ns, lnum, 0, { line_hl_group = 'GitConflictAncestorLabel', end_row = lnum + 1 })
    elseif line:match('^=======') then
      region = 'incoming'
      vim.api.nvim_buf_set_extmark(buf, conflict_ns, lnum, 0, { line_hl_group = 'GitConflictAncestorLabel', end_row = lnum + 1 })
    elseif line:match('^>>>>>>>') then
      vim.api.nvim_buf_set_extmark(buf, conflict_ns, lnum, 0, { line_hl_group = 'GitConflictIncomingLabel', end_row = lnum + 1 })
      region = nil
    elseif region == 'current' then
      vim.api.nvim_buf_set_extmark(buf, conflict_ns, lnum, 0, { line_hl_group = 'GitConflictCurrent', end_row = lnum + 1 })
    elseif region == 'ancestor' then
      vim.api.nvim_buf_set_extmark(buf, conflict_ns, lnum, 0, { line_hl_group = 'GitConflictAncestor', end_row = lnum + 1 })
    elseif region == 'incoming' then
      vim.api.nvim_buf_set_extmark(buf, conflict_ns, lnum, 0, { line_hl_group = 'GitConflictIncoming', end_row = lnum + 1 })
    end
  end
end

--- Debounced version of conflict_apply (200ms).
---@param buf number
function M.conflict_apply_debounced(buf)
  conflict_timer:stop()
  conflict_timer:start(200, 0, vim.schedule_wrap(function()
    M.conflict_apply(buf)
  end))
end

return M
