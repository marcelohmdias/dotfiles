local M = { "nvim-treesitter/nvim-treesitter" }

M.dependencies = {
  { "andreshazard/vim-freemarker", event = "LazyFile" },
  {
    "bezhermoso/tree-sitter-ghostty",
    build = "make nvim_install",
    event = "LazyFile",
  },
}

M.event = "VeryLazy"

function M.opts(_, opts)
  vim.list_extend(opts.ensure_installed, { "css", "gitignore", "graphql", "styled" })
end

return M
