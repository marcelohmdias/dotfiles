local M = { gh('folke/trouble.nvim') }

M.cmd = { 'Trouble' }

M.keys = {
  { '<leader>xx', cmd('Trouble diagnostics toggle'), desc = 'Diagnostics (Trouble)' },
  { '<leader>xX', cmd('Trouble diagnostics toggle filter.buf=0'), desc = 'Buffer Diagnostics (Trouble)' },
  { '<leader>cS', cmd('Trouble lsp toggle'), desc = 'LSP references/definitions/... (Trouble)' },
  { '<leader>xL', cmd('Trouble loclist toggle'), desc = 'Location List (Trouble)' },
  { '<leader>xQ', cmd('Trouble qflist toggle'), desc = 'Quickfix List (Trouble)' },
  {
    '[q',
    function()
      if require('trouble').is_open() then
        require('trouble').prev({ skip_groups = true, jump = true })
      else
        local ok, err = pcall(vim.cmd.cprev)
        if not ok then vim.notify(err, vim.log.levels.ERROR) end
      end
    end,
    desc = 'Previous Trouble/Quickfix Item',
  },
  {
    ']q',
    function()
      if require('trouble').is_open() then
        require('trouble').next({ skip_groups = true, jump = true })
      else
        local ok, err = pcall(vim.cmd.cnext)
        if not ok then vim.notify(err, vim.log.levels.ERROR) end
      end
    end,
    desc = 'Next Trouble/Quickfix Item',
  },
}

---@module 'trouble'
---@type trouble.Config
M.opts = {
  modes = {
    lsp = {
      win = { position = 'right' },
    },
  },
}

return M
