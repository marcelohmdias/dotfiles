local Format = require "utils.format"

local M = {}

-- APPS
M.launch_menu = {
  { args = { "tig" }, label = Format:to_format("Tig", "  - ") },
  { args = { "htop" }, label = Format:to_format("HTop", "  - ") },
  { args = { "btop" }, label = Format:to_format("BTop", "  - ") },
  { args = { "lazygit" }, label = Format:to_format("LazyGit", "  - ") },
}

return M
