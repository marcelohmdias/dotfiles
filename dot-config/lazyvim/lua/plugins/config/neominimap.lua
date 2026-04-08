local M = { "Isrothy/neominimap.nvim" }

M.version = "v3.x.x"

---@module "neominimap.config.meta.init"
M.init = function()
  ---@class Neominimap.UserConfig
  vim.g.neominimap = {
    auto_enable = true,
    click = {
      enabled = true,
    },
    exclude_buftypes = {
      "dashboard",
      "help",
      "lazy",
      "lazyterm",
      "mason",
      "neo-tree",
      "nofile",
      "notify",
      "nowrite",
      "prompt",
      "qf",
      "quickfix",
      "Telescope",
      "Trouble",
      "trouble",
    },
    exclude_filetypes = {
      "help",
      "bigfile",
    },
    margin = {
      right = 10,
      top = 0,
      bottom = 0,
    },
  }
  vim.opt.sidescrolloff = 36
  vim.opt.wrap = false
end

M.keys = {
  {
    "<leader>uM",
    "<cmd>Neominimap Toggle<cr>",
    desc = "Toggle Minimap",
  },
}

M.lazy = false

return M
