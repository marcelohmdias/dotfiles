local M = { "aaronik/treewalker.nvim" }

M.event = "LazyFile"

M.keys = {
  { "gwh", "<Cmd>Treewalker Left<CR>", desc = "Treewalker Left" },
  { "gwj", "<Cmd>Treewalker Down<CR>", desc = "Treewalker Down" },
  { "gwk", "<Cmd>Treewalker Up<CR>", desc = "Treewalker Up" },
  { "gwl", "<Cmd>Treewalker Right<CR>", desc = "Treewalker Right" },
}

M.opts = {
  highlight = true,
}

return M
