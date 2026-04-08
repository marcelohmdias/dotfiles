local utils = require("config.utils")

local M = { "folke/snacks.nvim" }

---@module "snacks"
---@param opts snacks.Config
function M.opts(_, opts)
  ---@class snacks.win.Config
  local win = { border = vim.g.modal_border }

  opts.win = utils.merge(opts.win, win)

  return opts
end

return M
