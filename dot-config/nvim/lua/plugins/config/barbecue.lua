local M = { "utilyre/barbecue.nvim" }

M.dependencies = {
  "SmiteshP/nvim-navic",
  "nvim-tree/nvim-web-devicons",
}

M.event = "LazyFile"

M.name = "barbecue"

--- @class barbecue.Config
M.opts = {
  kinds = require("config.icons").kinds,
  theme = "auto",
}

return M
