local Format = require "utils.format"

local M = {}

-- APPS
M.launch_menu = {
  { args = { "yazi" }, label = Format:to_format("Yazi", "  - ") },
  { args = { "btop" }, label = Format:to_format("BTop", "  - ") },
  { args = { "gh dash" }, label = Format:to_format("Gh Dash", "  - ") },
  { args = { "lazygit" }, label = Format:to_format("LazyGit", "  - ") },
  { args = { "tig" }, label = Format:to_format("Tig", "  - ") },
}

return M
