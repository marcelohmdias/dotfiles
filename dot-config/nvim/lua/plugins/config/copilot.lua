-- Copilot native inline completion keymaps
-- Config-only spec: LSP config lives in lsp/copilot.lua

local M = {}

-- stylua: ignore
M.config = function()
  map({ 'i', 'n' }, '<M-]>', function() vim.lsp.inline_completion.select({ count = 1 }) end, { desc = 'Next Copilot Suggestion' })
  map({ 'i', 'n' }, '<M-[>', function() vim.lsp.inline_completion.select({ count = -1 }) end, { desc = 'Prev Copilot Suggestion' })
end

M.enabled = vim.g.copilot_enabled

M.event = 'LspAttach'

M.name = 'copilot'

return M
