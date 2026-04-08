local M = { "toppair/peek.nvim" }

M.build = "deno task --quiet build:fast"

function M.config()
  require("peek").setup({})
  vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
  vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
end

M.event = "LazyFile"

return M
