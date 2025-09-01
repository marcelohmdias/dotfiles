local M = { "gbprod/yanky.nvim" }

M.event = "LazyFile"

M.keys = {
  {
    "<leader>p",
    function()
      require("telescope").extensions.yank_history.yank_history({})
    end,
    mode = { "n", "x" },
    desc = "Open Yank History",
  },
}

M.opts = {}

return M
