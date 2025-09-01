local M = { "christoomey/vim-tmux-navigator" }


M.cmd = {
  "TmuxNavigateLeft",
  "TmuxNavigateDown",
  "TmuxNavigateUp",
  "TmuxNavigateRight",
  "TmuxNavigatePrevious",
}

M.keys = {
  { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
  { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
  { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
  { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
  { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
}

return M
