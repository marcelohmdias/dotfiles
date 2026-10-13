local M = { gh('chrisgrieser/nvim-origami') }

M.event = 'LazyFile'

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
