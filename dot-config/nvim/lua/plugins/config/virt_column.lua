local M = { gh('lukas-reineke/virt-column.nvim') }

M.event = 'LazyFile'

function M.config()
  require('virt-column').setup({
    char = '│',
    exclude = {
      filetype = {
        'dashboard',
        'lazy',
        'neo-tree',
        'neo-tree-popup',
        'noice',
        'notify',
        'prompt',
      },
    },
    virtcolumn = '120',
  })
end

return M
