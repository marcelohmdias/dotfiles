local C = require("catppuccin.palettes").get_palette()
local icons = require("config.icons")

local M = { "vuki656/package-info.nvim" }

M.dependencies = {
  { "MunifTanjim/nui.nvim", event = "VeryLazy" },
}

M.event = "LazyFile"

M.ft = { "json" }

M.opts = {
  highlights = {
    up_to_date = { fg = C.teal },
    outdated = { fg = C.peach },
    invalid = { fg = C.red },
  },
  icons = {
    enable = true,
    style = {
      up_to_date = icons.git.staged,
      outdated = icons.git.removed,
      invalid = icons.alerts.error,
    },
  },
  autostart = true,
  hide_up_to_date = true,
  hide_unstable_versions = false,
  package_manager = "npm",
}

M.keys = function()
  local pi = require("package-info")

  require("which-key").add({
    { "<leader>Is", pi.show, desc = "Show package info" },
    { "<leader>Ih", pi.hide, desc = "Hide package info" },
    { "<leader>In", pi.toggle, desc = "Toggle package info" },
    { "<leader>Iu", pi.update, desc = "Update package" },
    { "<leader>Id", pi.delete, desc = "Delete package" },
    { "<leader>Ii", pi.install, desc = "Install package" },
    { "<leader>Iv", pi.change_version, desc = "Change package version" },
  })
end

return M
