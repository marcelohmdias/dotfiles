local M = { "folke/zen-mode.nvim" }

M.cmd = "ZenMode"

M.event = "VeryLazy"

M.opts = {
  on_close = function()
    require("barbecue.ui").toggle(true)
    require("noice").enable()
    require("ufo").enable()
    vim.g.miniindentscope_disable = false
    vim.o.cmdheight = 0
  end,
  on_open = function()
    require("barbecue.ui").toggle(false)
    require("noice").disable()
    require("ufo").disable()
    vim.g.miniindentscope_disable = true
    vim.o.cmdheight = 1
  end,
  plugins = {
    gitsigns = {
      enabled = true,
    },
    options = {
      laststatus = 0,
    },
    tmux = {
      enabled = true,
    },
    wezterm = {
      enabled = true,
      font = "15",
    },
  },
  window = {
    options = {
      number = true,
      relativenumber = false,
      list = false,
    },
    zindex = 10,
  },
}

return M
