local M = { "stevearc/aerial.nvim" }

M.event = "LazyFile"

M.opts = {
  filter_kind = {
    "Class",
    "Constant",
    "Constructor",
    "Enum",
    "Function",
    "Interface",
    "Module",
    "Method",
    "Struct",
    "Type",
  },
}

return M
