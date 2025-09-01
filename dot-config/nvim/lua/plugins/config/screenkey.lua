local M = { "NStefan002/screenkey.nvim" }

M.cmd = "Screenkey"

M.keys = {
  { "<leader>uk", "<cmd>Screenkey toggle<cr>", desc = "Toggle Screen" },
}

M.lazy = true

M.opts = {
  win_opts = {
    border = vim.g.modal_border,
    title = " Screenkey ",
  },
}

M.version = "*"

return M
