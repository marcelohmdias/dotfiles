local M = { "f-person/git-blame.nvim" }

M.cmd = {
  "GitBlameDisable",
  "GitBlameEnable",
  "GitBlameToggle",
}

M.keys = {
  { "<leader>uB", "<cmd>GitBlameToggle<cr>", desc = "Toggle Git Blame" },
}

M.opts = {
  enabled = false,
}

return M
