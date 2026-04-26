local M = { gh('folke/snacks.nvim') }

-- Terminal navigation helper
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and '<c-' .. dir .. '>' or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

-- stylua: ignore
M.keys = {
  { '<leader>.', function() Snacks.scratch() end, desc = 'Toggle Scratch Buffer' },
  { '<leader>S', function() Snacks.scratch.select() end, desc = 'Select Scratch Buffer' },
  { '<leader>n', function()
    if Snacks.config.picker and Snacks.config.picker.enabled then
      Snacks.picker.notifications()
    else
      Snacks.notifier.show_history()
    end
  end, desc = 'Notification History' },
  { '<leader>un', function() Snacks.notifier.hide() end, desc = 'Dismiss All Notifications' },
  { '<leader>dps', function() Snacks.profiler.scratch() end, desc = 'Profiler Scratch Buffer' },
}

M.lazy = false

---@module 'snacks'
---@type snacks.Config
M.opts = {
  bigfile = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },
  terminal = {
    win = {
      keys = {
        nav_h = { '<C-h>', term_nav('h'), desc = 'Go to Left Window', expr = true, mode = 't' },
        nav_j = { '<C-j>', term_nav('j'), desc = 'Go to Lower Window', expr = true, mode = 't' },
        nav_k = { '<C-k>', term_nav('k'), desc = 'Go to Upper Window', expr = true, mode = 't' },
        nav_l = { '<C-l>', term_nav('l'), desc = 'Go to Right Window', expr = true, mode = 't' },
        hide_slash = { '<C-/>', 'hide', desc = 'Hide Terminal', mode = 't' },
        hide_underscore = { '<C-_>', 'hide', desc = 'which_key_ignore', mode = 't' },
      },
    },
  },
  words = { enabled = true },
}

return M
