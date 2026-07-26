local M = { gh('nvim-treesitter/nvim-treesitter-context') }

M.config = function(_, opts)
  require('treesitter-context').setup(opts)
  local tsc = require('treesitter-context')
  Snacks.toggle({
    name = 'Treesitter Context',
    get = tsc.enabled,
    set = function(state)
      if state then
        tsc.enable()
      else
        tsc.disable()
      end
    end,
  }):map('<leader>ut')
end

M.event = 'LazyFile'

---@module 'treesitter-context'
---@type TSContext.UserConfig
M.opts = { mode = 'cursor', max_lines = 3 }

return M
