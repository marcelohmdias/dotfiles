local M = { gh('folke/lazydev.nvim') }

M.cmd = 'LazyDev'
M.ft = 'lua'

---@module 'lazydev'
---@type lazydev.Config
M.opts = {
  library = {
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    { path = 'mini.icons', words = { 'MiniIcons' } },
    { path = 'mini.misc', words = { 'MiniMisc' } },
    { path = 'mini.session', words = { 'MiniSessions' } },
    { path = 'snacks.nvim', words = { 'Snacks' } },
  },
}

return M
