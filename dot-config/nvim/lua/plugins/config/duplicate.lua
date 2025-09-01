local M = { "hinell/duplicate.nvim" }

M.event = "LazyFile"

M.keys = {
  { "<leader>cd", "<cmd>VisualDuplicate +1<cr>", desc = "Duplicate to down", mode = { "v" } },
  { "<leader>cD", "<cmd>VisualDuplicate -1<cr>", desc = "Duplicate to up", mode = { "v" } },
}

return M
