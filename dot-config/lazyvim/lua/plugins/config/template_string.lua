local M = { "axelvc/template-string.nvim" }

function M.config()
  require("template-string").setup({})
end

M.event = "LazyFile"

return M
