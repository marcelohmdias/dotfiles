local utils = require("config.utils")

local M = { "folke/snacks.nvim" }

---@module "snacks"
---@param opts snacks.Config
function M.opts(_, opts)
  ---@class snacks.image.Config
  local image = {
    force = true,
  }

  opts.image = utils.merge(opts.image, image)

  return opts
end

return M
