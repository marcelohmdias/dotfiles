local M = { "aznhe21/actions-preview.nvim" }

M.event = "LazyFile"

M.keys = {
  {
    "<leader>cP",
    function()
      require("actions-preview").code_actions()
    end,
    desc = "Code Actions Preview",
  },
}

M.opts = {}

return M
