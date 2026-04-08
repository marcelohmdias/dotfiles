local theme_colors = require("catppuccin.palettes")

local M = { "rachartier/tiny-devicons-auto-colors.nvim" }

M.dependencies = {
  { "nvim-tree/nvim-web-devicons", event = "VeryLazy" },
}

M.event = "VeryLazy"

function M.config()
  require("tiny-devicons-auto-colors").setup({
    colors = theme_colors.get_palette(),
  })
end

return M
