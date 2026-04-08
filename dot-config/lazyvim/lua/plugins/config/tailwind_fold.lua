local C = require("catppuccin.palettes").get_palette()

local M = { "razak17/tailwind-fold.nvim" }

M.dependencies = { "nvim-treesitter/nvim-treesitter" }

M.event = "LazyFile"

M.keys = {
  {
    "<leader>uH",
    "<Cmd>TailwindFoldToggle<CR>",
    desc = "Toggle CSS class fold",
  },
}

M.opts = {
  ft = {
    "astro",
    "html",
    "javascriptreact",
    "svelte",
    "typescriptreact",
    "vue",
  },
  highlight = { fg = C.blue },
}

return M
