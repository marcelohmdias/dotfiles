--- MiniPack status module.
--- Provides startup stats and update status compatible with snacks.nvim dashboard.

local M = {}

---@class MiniPackStats
M._stats = {
  count = 0,
  loaded = 0,
  real_cputime = false,
  startuptime = 0,
  ---@type table<string, number>
  times = {},
}

--- Foundation plugins loaded outside MiniPack (always counted as loaded).
M._foundation = { 'catppuccin', 'mini.icons', 'mini.misc', 'snacks.nvim' }

---@type ffi.namespace*
M._C = nil

---@type table|false
local _ffi

function M.cputime()
  if M._C == nil then
    local ok = pcall(function()
      _ffi = require('ffi')
      _ffi.cdef([[
        typedef int clockid_t;
        typedef struct timespec {
          int64_t tv_sec;
          long    tv_nsec;
        } nanotime;
        int clock_gettime(clockid_t clk_id, struct timespec *tp);
      ]])
      M._C = _ffi.C
    end)
    if not ok then
      M._C = false
      _ffi = false
    end
  end

  if M._C and _ffi then
    local pnano = _ffi.new('nanotime[1]')
    local CLOCK_PROCESS_CPUTIME_ID = jit.os == 'OSX' and 12 or 2
    M._C.clock_gettime(CLOCK_PROCESS_CPUTIME_ID, pnano)
    M._stats.real_cputime = true
    return tonumber(pnano[0].tv_sec) * 1e3 + tonumber(pnano[0].tv_nsec) / 1e6
  else
    return vim.uv.hrtime() / 1e6
  end
end

function M.track(event)
  local time = M.cputime()
  M._stats.times[event] = time
  return time
end

function M.on_ui_enter()
  M._stats.startuptime = M.cputime()
end

--- Pack path (overridable for testing).
M._pack_path = require('core.pkg.sources').PACK_PATH

--- Cached disk count (invalidated on PackChanged).
---@type number?
local cached_count = nil

--- Invalidate cache on plugin changes.
vim.api.nvim_create_autocmd('User', {
  pattern = 'PackChanged',
  callback = function()
    cached_count = nil
  end,
})

--- Get stats compatible with lazy.stats interface.
---@return MiniPackStats
function M.stats()
  local loader = require('core.pkg.loader')
  local ps = loader.plugin_stats()

  -- Count installed plugins from disk (cached)
  if not cached_count then
    cached_count = 0
    if vim.fn.isdirectory(M._pack_path) == 1 then
      local handle = vim.uv.fs_scandir(M._pack_path)
      if handle then
        while true do
          local name, ftype = vim.uv.fs_scandir_next(handle)
          if not name then break end
          if ftype == 'directory' then cached_count = cached_count + 1 end
        end
      end
    end
  end

  M._stats.count = cached_count

  -- Add foundation plugins not tracked by loader (e.g. mini.misc, mini.icons, catppuccin)
  -- Snacks has a MiniPack spec so it's already in ps.loaded
  local extra = 0
  for _, name in ipairs(M._foundation) do
    if not loader.is_loaded(name) then
      extra = extra + 1
    end
  end
  M._stats.loaded = ps.loaded + extra
  return M._stats
end

--- Get update status string for statusline.
---@return string
function M.updates()
  local count = MiniPack.pending_count and MiniPack.pending_count() or 0
  return count > 0 and (' ' .. count) or ''
end

--- Check if updates are available.
---@return boolean
function M.has_updates()
  local count = MiniPack.pending_count and MiniPack.pending_count() or 0
  return count > 0
end

return M
