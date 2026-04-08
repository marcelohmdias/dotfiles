local M = { "tanvirtin/vgit.nvim" }

M.dependencies = {
  "nvim-lua/plenary.nvim",
  "nvim-tree/nvim-web-devicons",
}

M.event = "LazyFile"

M.keys = {
  {
    "<leader>uB",
    function()
      require("vgit").toggle_live_blame()
    end,
    desc = "Toggle Git Blame",
  },
}

M.opts = {
  settings = {
    live_blame = {
      enabled = false,
    },
  },
}

return M
