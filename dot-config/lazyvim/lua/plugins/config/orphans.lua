local M = { "ZWindL/orphans.nvim" }

function M.config()
  require("orphans").setup({})
end

M.event = "VeryLazy"

M.keys = {
  { "<leader>Co", "<Cmd>Orphans<CR>", desc = "Show Orphans Plugins" },
}

return M
