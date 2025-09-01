local M = { "gorbit99/codewindow.nvim" }

function M.config()
  local codewindow = require("codewindow")
  local screen_bounds = vim.g.transparent_enabled and "lines" or "background"

  codewindow.setup({
    auto_enable = false,
    events = {
      "BufEnter",
      "BufNewFile",
      "BufRead",
      "DiagnosticChanged",
      "FileWritePost",
      "InsertLeave",
      "LspAttach",
      "TextChanged",
    },
    exclude_filetypes = {
      "dashboard",
      "help",
      "lazy",
      "lazyterm",
      "mason",
      "neo-tree",
      "nofile",
      "notify",
      "nowrite",
      "prompt",
      "qf",
      "quickfix",
      "Telescope",
      "Trouble",
      "trouble",
    },
    relative = "win",
    screen_bounds = screen_bounds,
    width_multiplier = 3,
    window_border = vim.g.modal_border,
  })
end

M.keys = {
  {
    "<leader>uM",
    function()
      require("codewindow").toggle_minimap()
    end,
    desc = "Toggle Minimap",
  },
}

M.lazy = true

return M
