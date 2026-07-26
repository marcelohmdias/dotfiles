local M = { gh('nvzone/showkeys') }

M.cmd = 'ShowkeysToggle'

M.keys = {
  { '<leader>uk', cmd('ShowkeysToggle'), desc = 'Toggle ShowKeys' },
}

M.opts = {
  config = {
    winopts = {
      border = vim.g.border,
    },
  },
  maxkeys = 6,
  position = 'bottom-center',
  timeout = 1,
}

return M
