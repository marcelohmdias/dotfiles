local M = { gh('saghen/blink.indent') }

M.event = 'LazyFile'

---@module 'blink.indent'
---@type blink.indent.Config
M.opts = {
  indent = {
    char = '│',
  },
  scope = {
    char = '│',
    highlights = { 'BlinkIndentScope' },
  },
}

return M
