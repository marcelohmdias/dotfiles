-- Minimal init for mini.test child processes
-- Enables vim.loader + adds mini packages to rtp

vim.loader.enable()

local pack_root = vim.fn.stdpath('data') .. '/site/pack/core/opt'

-- Add all mini packages to rtp
for _, pkg in ipairs({ 'mini.misc', 'mini.icons', 'mini.test' }) do
  vim.opt.rtp:prepend(pack_root .. '/' .. pkg)
end

-- Add project root to runtime path so require('core.*') works
local project_root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h:h')
vim.opt.rtp:prepend(project_root)
