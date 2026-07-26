local M = { gh('folke/todo-comments.nvim') }

M.cmd = { 'TodoTrouble' }
M.event = 'LazyFile'

-- stylua: ignore
M.keys = {
  { ']t', function() require('todo-comments').jump_next() end, desc = 'Next Todo Comment' },
  { '[t', function() require('todo-comments').jump_prev() end, desc = 'Previous Todo Comment' },
  { '<leader>xt', cmd('Trouble todo toggle'), desc = 'Todo (Trouble)' },
  { '<leader>xT', cmd('Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}'), desc = 'Todo/Fix/Fixme (Trouble)' },
  { '<leader>st', function() Snacks.picker.todo_comments() end, desc = 'Todo' },
  { '<leader>sT', function() Snacks.picker.todo_comments({ keywords = { 'TODO', 'FIX', 'FIXME' } }) end, desc = 'Todo/Fix/Fixme' },
}

---@module 'todo-comments'
---@type TodoConfig
M.opts = {}

return M
