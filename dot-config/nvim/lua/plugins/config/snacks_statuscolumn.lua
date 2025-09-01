local utils = require("config.utils")

local M = { "folke/snacks.nvim" }

---@module "snacks"
---@param opts snacks.Config
function M.opts(_, opts)
  ---@class snacks.statuscolumn.Config
  local statuscolumn = {
    left = { "mark", "fold", "sign" },
    right = { "git" },
    folds = { open = true },
  }

  opts.statuscolumn = utils.merge(opts.statuscolumn, statuscolumn)

  return opts
end

return M
