local M = { "axieax/urlview.nvim" }

M.cmd = "UrlView"

function M.config()
  require("urlview").setup({})
end

M.keys = {
  { "<leader>fU", "<Cmd>UrlView<CR>", desc = "Find Buffer URLs" },
  { "<leader>Cu", "<Cmd>UrlView lazy<CR>", desc = "Config Plugins URL" },
}

M.lazy = true

return M
