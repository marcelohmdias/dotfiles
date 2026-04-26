local M = { gh('brenoprata10/nvim-highlight-colors') }

M.event = 'LazyFile'
M.name = 'nvim-highlight-colors'

function M.config(_, opts)
  require('nvim-highlight-colors').setup(opts)
end
M.opts = {
  enable_named_colors = false,
  render = 'virtual',
  virtual_symbol = ' ',
}

return M
