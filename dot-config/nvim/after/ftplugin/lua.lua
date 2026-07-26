-- Lua filetype settings

-- Run Lua code
vim.keymap.set({ 'n', 'x' }, '<localleader>r', function()
  Snacks.debug.run()
end, { buffer = true, desc = 'Run Lua' })
