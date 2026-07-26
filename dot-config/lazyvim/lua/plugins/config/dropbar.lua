local M = { "Bekaboo/dropbar.nvim" }

M.dependencies = {
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
}

M.event = "LazyFile"

M.name = "dropbar"

---@class dropbar_configs_t
M.opts = {
  icons = {
    kinds = {
      dir_icon = function()
        return nil, nil
      end,
    },
  },
  menu = {
    preview = false,
    scrollbar = { enable = false },
    win_configs = {
      border = vim.g.modal_border,
    },
  },
}

return M
