local icons = require("config.icons")

local M = { "folke/which-key.nvim" }

M.lazy = true

---@class wk.Opts
M.opts = {
  icons = {
    rules = {
      { pattern = "bookmark", icon = icons.misc.mark, color = "red" },
      { pattern = "config", icon = icons.misc.stack, color = "purple" },
      { pattern = "diff", cat = "filetype", name = "git" },
      { pattern = "mark", icon = icons.misc.mark, color = "red" },
      { pattern = "goto", icon = icons.misc.goto, color = "blue" },
      { pattern = "go to", icon = icons.misc.goto, color = "blue" },
      { pattern = "overseer", icon = icons.misc.task, color = "green" },
      { pattern = "package", icon = icons.kinds.Module, color = "orange" },
      { pattern = "precognition", icon = icons.misc.robot, color = "purple" },
      { pattern = "project", icon = icons.misc.project, color = "azure" },
      { pattern = "yazi", icon = icons.misc.duck, color = "yellow" },
    },
  },
  preset = "classic",
  spec = {
    {
      mode = { "n", "v" },
      { "<leader>C", group = "Config Files" },
      { "<leader>I", group = "PackageInfo" },
      { "<leader>M", group = "Bookmarks" },
      { "gc", group = "Coerce" },
      { "gG", group = "Glance" },
      { "gw", group = "Treewalker" },
    },
  },
  win = {
    border = vim.g.transparent_enabled and "single" or "none",
  },
}

return M
