local M = { gh('MagicDuck/grug-far.nvim') }

M.cmd = { 'GrugFar', 'GrugFarWithin' }

M.keys = {
  {
    '<leader>sr',
    function()
      local grug = require('grug-far')
      local ext = vim.bo.buftype == '' and vim.fn.expand('%:e')
      grug.open({
        transient = true,
        prefills = {
          filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
        },
      })
    end,
    mode = { 'n', 'x' },
    desc = 'Search and Replace',
  },
}

---@module 'grug-far'
---@type grug-far.Config
M.opts = {
  headerMaxWidth = 80,
}

return M
