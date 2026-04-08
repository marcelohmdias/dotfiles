local utils = require("config.utils")

local M = { "folke/noice.nvim" }

function M.opts(_, opts)
  local presets = {
    inc_rename = false,
    lsp_doc_border = vim.g.transparent_enabled,
  }

  opts.presets = utils.merge(opts.presets, presets)

  return opts
end

return M
