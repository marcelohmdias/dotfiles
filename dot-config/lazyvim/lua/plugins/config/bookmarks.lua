local C = require("catppuccin.palettes").get_palette()
local icons = require("config.icons")

local M = { "LintaoAmons/bookmarks.nvim" }

M.cmd = {
  "BookmarksCommands",
  "BookmarksEditJsonFile",
  "BookmarksGoto",
  "BookmarksGotoRecent",
  "BookmarksMark",
  "BookmarksReload",
}

M.dependencies = {
  { "kkharji/sqlite.lua" },
  { "nvim-telescope/telescope.nvim" },
  { "stevearc/dressing.nvim" },
}

M.keys = {
  { "<leader>Ma", "<Cmd>BookmarksCommands<CR>", desc = "Bookmarks Commands" },
  { "<leader>Mg", "<Cmd>BookmarksGoto<CR>", desc = "Go to Bookmarks" },
  { "<leader>Mm", "<Cmd>BookmarksMark<CR>", desc = "Mark current line" },
  { "<leader>Mr", "<Cmd>BookmarksGotoRecent<CR>", desc = "Go to last visited" },
}

M.opts = {
  signs = {
    mark = { icon = icons.misc.mark, color = C.red },
  },
}

return M
