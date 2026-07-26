local M = { gh('windwp/nvim-ts-autotag') }

M.config = function(_, opts)
  require('nvim-ts-autotag').setup(opts)
end

M.event = 'LazyFile'

---@module 'nvim-ts-autotag'
---@type nvim-ts-autotag.UserConfig
M.opts = {}

return M
