local M = { gh('nickjvandyke/opencode.nvim') }

M.config = function(_, opts)
  ---@type opencode.Opts
  vim.g.opencode_opts = vim.tbl_deep_extend('force', {
    server = {
      start = function()
        Snacks.terminal.open('opencode --port', {
          win = {
            position = 'right',
            enter = false,
            on_win = function(win)
              require('opencode.terminal').setup(win.win)
            end,
          },
        })
      end,
    },
  }, opts)
end

-- stylua: ignore
M.keys = {
  { '<leader>aa', function() require('opencode').ask('@this: ', { submit = true }) end, mode = { 'n', 'x' }, desc = 'Ask OpenCode' },
  { '<leader>as', function() require('opencode').select() end, mode = { 'n', 'x' }, desc = 'Execute OpenCode Action' },
  { '<leader>at', function() require('opencode').toggle() end, mode = { 'n', 't' }, desc = 'Toggle OpenCode' },
  { '<leader>ao', function() return require('opencode').operator('@this ') end, desc = 'Add Range to OpenCode', expr = true },
  { '<leader>al', function() return require('opencode').operator('@this ') .. '_' end, desc = 'Add Line to OpenCode', expr = true },
}

---@module 'opencode'
---@type opencode.Opts
M.opts = {}

M.version = '*'

return M
