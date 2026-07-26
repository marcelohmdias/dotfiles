local M = { gh('Isrothy/neominimap.nvim') }

M.event = 'LazyFile'

M.init = function()
  vim.opt.sidescrolloff = 36
  vim.opt.wrap = false

  ---@module 'neominimap.config'
  ---@type Neominimap.UserConfig
  vim.g.neominimap = {
    auto_enable = true,
    click = {
      enabled = true,
    },
    exclude_buftypes = {
      'dashboard',
      'help',
      'lazy',
      'lazyterm',
      'mason',
      'neo-tree',
      'nofile',
      'notify',
      'nowrite',
      'prompt',
      'qf',
      'quickfix',
      'Telescope',
      'Trouble',
      'trouble',
    },
    exclude_filetypes = {
      'bigfile',
      'help',
      'snacks_dashboard',
      'snacks_picker',
      'snacks_picker_input',
      'snacks_picker_list',
      'snacks_picker_preview',
    },
    float = {
      window_border = 'none',
    },
    margin = {
      right = 0,
      top = 0,
      bottom = 0,
    },
  }
end

M.keys = {
  { '<leader>uM', cmd('Neominimap Toggle'), desc = 'Toggle Minimap' },
}

return M
