local icons = require('core.icons')

local M = { gh('akinsho/bufferline.nvim') }

M.config = function(_, opts)
  require('bufferline').setup(opts)
  vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
    callback = function()
      vim.schedule(function()
        pcall(vim.cmd.redrawtabline)
      end)
    end,
  })
end

M.event = 'LazyFile'

M.keys = {
  { '<leader>bp', cmd('BufferLineTogglePin'), desc = 'Toggle Pin' },
  { '<leader>bP', cmd('BufferLineGroupClose ungrouped'), desc = 'Delete Non-Pinned Buffers' },
  { '<leader>bl', cmd('BufferLineCloseLeft'), desc = 'Delete Buffers to the Left' },
  { '<leader>br', cmd('BufferLineCloseRight'), desc = 'Delete Buffers to the Right' },
  { '<leader>bj', cmd('BufferLinePick'), desc = 'Pick Buffer' },
  { '<S-h>', cmd('BufferLineCyclePrev'), desc = 'Prev Buffer' },
  { '<S-l>', cmd('BufferLineCycleNext'), desc = 'Next Buffer' },
  { '[b', cmd('BufferLineCyclePrev'), desc = 'Prev Buffer' },
  { ']b', cmd('BufferLineCycleNext'), desc = 'Next Buffer' },
  { '[B', cmd('BufferLineMovePrev'), desc = 'Move buffer prev' },
  { ']B', cmd('BufferLineMoveNext'), desc = 'Move buffer next' },
}

M.opts = function()
  local C = require('catppuccin.palettes').get_palette()
  return {
    highlights = {
      indicator_selected = { fg = C.blue },
    },
    options = {
      always_show_bufferline = false,
      close_command = function(n)
        Snacks.bufdelete(n)
      end,
      diagnostics = 'nvim_lsp',
      indicator = { icon = '▎', style = 'icon' },
      diagnostics_indicator = function(_, _, diag)
        local ret = (diag.error and icons.alerts.error .. diag.error .. ' ' or '')
          .. (diag.warning and icons.alerts.warn .. diag.warning or '')
        return vim.trim(ret)
      end,
      offsets = {
        { filetype = 'snacks_layout_box' },
      },
      right_mouse_command = function(n)
        Snacks.bufdelete(n)
      end,
      separator_style = { '', '' },
    },
  }
end

return M
