local M = { "sindrets/diffview.nvim" }

M.dependencies = "nvim-lua/plenary.nvim"

M.cmd = {
  "DiffviewOpen",
  "DiffviewClose",
  "DiffviewToggleFiles",
  "DiffviewFocusFiles",
  "DiffviewRefresh",
  "DiffviewFileHistory",
}

M.keys = {
  { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open Diff View" },
  { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close Diff View" },
}

M.opts = {}

return M
