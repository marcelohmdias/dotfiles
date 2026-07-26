local M = { gh('danymat/neogen') }

M.cmd = 'Neogen'

-- stylua: ignore
M.keys = {
  { '<leader>cn', function() require('neogen').generate() end, desc = 'Generate Annotations (Neogen)' },
}

---@module 'neogen'
---@type neogen.Configuration
M.opts = {
  snippet_engine = 'nvim',
}

return M
