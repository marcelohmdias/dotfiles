local M = { "lukas-reineke/virt-column.nvim" }

function M.config()
  require("virt-column").setup({
    char = "│",
    exclude = {
      filetype = {
        "dashboard",
        "lazy",
        "neo-tree",
        "neo-tree-popup",
        "noice",
        "notify",
        "prompt",
      },
    },
    virtcolumn = "100",
  })
end

M.event = "LazyFile"

return M
