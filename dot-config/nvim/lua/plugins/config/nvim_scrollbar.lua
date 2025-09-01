local M = { "petertriho/nvim-scrollbar" }

M.event = "LazyFile"

M.opts = {
  excluded_filetypes = {
    "blink.cmp",
    "cmp_docs",
    "cmp_menu",
    "DressingInput",
    "dropbar_menu",
    "dropbar_menu_fzf",
    "lazy",
    "neo-tree",
    "neo-tree-popup",
    "noice",
    "prompt",
    "snacks_picker_list",
    "TelescopePrompt",
  },
}

return M
