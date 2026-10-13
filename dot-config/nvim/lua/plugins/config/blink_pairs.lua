local M = { gh('saghen/blink.pairs') }

M.dependencies = { gh('saghen/blink.download'), gh('saghen/blink.lib') }

M.event = 'LazyFile'

---@module 'blink.pairs'
---@type blink.pairs.Config
M.opts = {
  highlights = {
    groups = { 'BlinkPairs' },
  },
}

M.version = '*'

return M
