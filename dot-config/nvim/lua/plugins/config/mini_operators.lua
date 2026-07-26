local M = { gh('echasnovski/mini.operators') }

M.event = 'LazyFile'

---@module 'mini.operators'
---@type table
M.opts = {
  duplicate = { prefix = 'god' },
  evaluate = { prefix = 'goe' },
  exchange = { prefix = 'gox' },
  multiply = { prefix = 'gom' },
  replace = { prefix = 'gor' },
  sort = { prefix = 'gos' },
}

return M
