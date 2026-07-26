local M = { gh('Wansmer/treesj') }

-- stylua: ignore
M.keys = {
  { 'J', function() require('treesj').toggle() end, desc = 'Join/Split' },
}

---@module 'treesj'
---@type treesj.Opts
M.opts = {
  max_join_length = 150,
  use_default_keymaps = false,
}

return M
