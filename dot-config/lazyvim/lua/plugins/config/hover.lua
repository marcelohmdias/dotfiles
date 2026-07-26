local M = { "lewis6991/hover.nvim" }

M.event = "LazyFile"

--- @class Hover.Config
M.opts = {
  init = function()
    -- Require providers
    require("hover.providers.lsp")
    require("hover.providers.diagnostic")
    require("hover.providers.dictionary")
    require("hover.providers.dap")
    require("hover.providers.fold_preview")
    require("hover.providers.gh")
    require("hover.providers.gh_user")
    require("hover.providers.man")
    -- require('hover.providers.jira')
  end,
  mouse_delay = 1000,
  mouse_providers = {
    "LSP",
  },
  preview_opts = {
    border = vim.g.modal_border,
  },
  preview_window = true,
  title = true,
}

function M.keys()
  local hover = require("hover")

  require("which-key").add({
    { "K", hover.hover, desc = "Signature help", mode = { "n" } },
    { "gK", hover.hover_select, desc = "Signature help", mode = { "n" } },
    { "<MouseMove>", hover.hover_mouse, desc = "hover.nvim", mode = { "n" } },
  })
end

return M
