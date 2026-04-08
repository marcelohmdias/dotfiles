local M = { "m4xshen/hardtime.nvim" }

M.dependencies = {
  { "MunifTanjim/nui.nvim", event = "VeryLazy" },
  { "nvim-lua/plenary.nvim", event = "VeryLazy" },
}

M.enabled = vim.g.hardtime

M.event = "LazyFile"

M.opts = {
  max_count = 5,
  restricted_keys = {
    ["<C-N>"] = {},
  },
}

return M
