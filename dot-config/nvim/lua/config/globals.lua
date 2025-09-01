vim.g.ai_cmp = true
vim.g.hardtime = false
vim.g.lazyvim_blink_main = true
vim.g.lazyvim_default_config = false
vim.g.lazyvim_prettier_needs_config = true
vim.g.precognition = true
vim.g.transparent_enabled = true

if not vim.g.transparent_enabled then
  vim.g.modal_border = "none"
  vim.g.winblend = vim.o.pumblend
else
  vim.g.modal_border = "rounded"
  vim.g.winblend = 0
end

if vim.env.VSCODE then
  vim.g.vscode = true
  vim.g.transparent_enabled = false
end

if vim.loader then
  vim.loader.enable()
end
