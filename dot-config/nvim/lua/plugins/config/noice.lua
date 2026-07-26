local M = { gh('folke/noice.nvim') }

M.config = function(_, opts)
  require('noice').setup(opts)
end

M.dependencies = { gh('MunifTanjim/nui.nvim') }
M.event = 'VeryLazy'

-- stylua: ignore
M.keys = {
  { '<leader>sn', '', desc = '+noice' },
  { '<S-Enter>', function() require('noice').redirect(vim.fn.getcmdline()) end, mode = 'c', desc = 'Redirect Cmdline' },
  { '<leader>snl', function() require('noice').cmd('last') end, desc = 'Noice Last Message' },
  { '<leader>snh', function() require('noice').cmd('history') end, desc = 'Noice History' },
  { '<leader>sna', function() require('noice').cmd('all') end, desc = 'Noice All' },
  { '<leader>snd', function() require('noice').cmd('dismiss') end, desc = 'Dismiss All' },
  { '<leader>snt', function() require('noice').cmd('pick') end, desc = 'Noice Picker' },
  { '<c-f>', function() if not require('noice.lsp').scroll(4) then return '<c-f>' end end, silent = true, expr = true, desc = 'Scroll Forward', mode = { 'i', 'n', 's' } },
  { '<c-b>', function() if not require('noice.lsp').scroll(-4) then return '<c-b>' end end, silent = true, expr = true, desc = 'Scroll Backward', mode = { 'i', 'n', 's' } },
}

---@module 'noice'
---@type NoiceConfig
M.opts = {
  lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = false,
    },
    signature = { enabled = false },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    inc_rename = true,
    long_message_to_split = true,
  },
  routes = {
    {
      filter = {
        event = 'msg_show',
        any = {
          { find = '%d+L, %d+B' },
          { find = '; after #%d+' },
          { find = '; before #%d+' },
        },
      },
      view = 'mini',
    },
  },
}

return M
