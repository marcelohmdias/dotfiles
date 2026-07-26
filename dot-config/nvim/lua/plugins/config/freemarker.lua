local M = { gh('andreshazard/vim-freemarker') }

M.ft = 'freemarker'

M.init = function()
  vim.filetype.add({
    extension = {
      ftl = 'freemarker',
    },
  })
end

return M
