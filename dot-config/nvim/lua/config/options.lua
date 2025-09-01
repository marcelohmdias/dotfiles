-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.diagnostic.config({
  virtual_text = { current_line = true },
})

vim.opt.endofline = true
vim.opt.fixendofline = true
vim.opt.signcolumn = "yes:2"

-- wrapping
vim.opt.colorcolumn = "100"
vim.opt.linebreak = true
vim.opt_local.textwidth = 100
vim.opt.wrap = true
