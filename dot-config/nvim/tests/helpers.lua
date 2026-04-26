---@diagnostic disable: undefined-global
-- Shared test helpers for mini.test suites
local H = {}

--- Create a child Neovim process with minimal_init loaded.
---@return table child MiniTest child neovim instance
function H.new_child()
  local child = MiniTest.new_child_neovim()
  child.start({ '-u', 'tests/minimal_init.lua' })
  return child
end

--- Project root (nvim config dir).
H.project_root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h:h')

return H
