local M = { gh('NeogitOrg/neogit') }

M.cmd = 'Neogit'

-- stylua: ignore
M.keys = {
  { '<leader>gn', cmd('Neogit'), desc = 'Neogit' },
}

---@module 'neogit'
---@type NeogitConfig
M.opts = {
  integrations = {
    codediff = true,
    snacks = true,
  },
}

return M
