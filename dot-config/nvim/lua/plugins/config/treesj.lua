local M = { "Wansmer/treesj" }

M.event = "LazyFile"

M.keys = {
  { "J", "<cmd>TSJToggle<cr>", desc = "Join Toggle" },
}

M.opts = {
  use_default_keymaps = false,
  max_join_length = 150,
}

return M
