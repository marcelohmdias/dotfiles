local M = { "2kabhishek/nerdy.nvim" }

M.cmd = "Nerdy"

M.dependencies = {
  "stevearc/dressing.nvim",
  "nvim-telescope/telescope.nvim",
}

M.keys = {
  { "<leader>fN", "<cmd>Nerdy<cr>", desc = "Find Nerd Fonts" },
}

M.lazy = true

return M
