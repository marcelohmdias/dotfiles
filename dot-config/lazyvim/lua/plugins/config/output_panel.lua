local M = { "mhanberg/output-panel.nvim" }

M.config = true

M.event = "VeryLazy"

M.keys = {
  { "<leader>uO", "<Cmd>OutputPanel<CR>", desc = "Toggle Output Panel" },
}

return M
