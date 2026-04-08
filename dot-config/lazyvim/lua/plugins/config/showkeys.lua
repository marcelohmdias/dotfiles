local M = { "nvzone/showkeys" }

M.cmd = "ShowkeysToggle"

M.event = "VeryLazy"

M.keys = {
  { "<leader>uk", "<cmd>ShowkeysToggle<cr>", desc = "Toggle ShowKeys" },
}

M.opts = {
  config = {
    winopts = {
      border = vim.g.modal_border,
    },
  },
  maxkeys = 6,
  position = "bottom-center",
  timeout = 1,
}

return M
