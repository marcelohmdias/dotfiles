local M = { "DreamMaoMao/yazi.nvim" }

M.cmd = {
  "Yazi",
}

M.dependencies = {
  "nvim-telescope/telescope.nvim",
  "nvim-lua/plenary.nvim",
}

M.keys = {
  { "<leader>fy", "<cmd>Yazi<CR>", desc = "Yazi" },
}

M.lazy = true

return M
