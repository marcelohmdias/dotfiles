local M = { gh('chrisgrieser/nvim-origami') }

M.event = 'LazyFile'

function M.init()
  vim.opt.foldlevel = 99
  vim.opt.foldlevelstart = 99
end

---@module 'origami'
---@type table
M.opts = {
  foldtext = {
    lineCount = {
      template = ' 󰁂 %d lines ',
      hlgroup = 'Comment',
    },
  },
}

return M
