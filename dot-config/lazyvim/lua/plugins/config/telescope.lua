local icons = require("config.icons")
local merge = require("config.utils").merge

local M = { "nvim-telescope/telescope.nvim" }

M.dependencies = {
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make", event = "VeryLazy" },
  { "nvim-lua/plenary.nvim", event = "VeryLazy" },
  { "nvim-lua/popup.nvim", event = "VeryLazy" },
  { "nvim-telescope/telescope-media-files.nvim", event = "VeryLazy" },
  { "vuki656/package-info.nvim", event = "LazyFile" },
  { "piersolenski/telescope-import.nvim", event = "LazyFile" },
  { "tsakirist/telescope-lazy.nvim", event = "VeryLazy" },
}

M.keys = {
  {
    "<leader>fi",
    "<cmd>Telescope import<cr>",
    desc = "Import Modules",
  },
  {
    "<leader>fP",
    "<cmd>Telescope package_info<cr>",
    desc = "Packages",
  },
  { "<leader>Cg", "<cmd>Telescope lazy<cr>", desc = "Config Plugins Page" },
}

M.opts = {
  defaults = {
    file_ignore_patterns = { ".git/", "node_modules" },
    layout_config = { prompt_position = "top", vertical = { mirror = true } },
    layout_strategy = "flex",
    prompt_prefix = icons.misc.telescope,
    selection_caret = icons.misc.select,
    sorting_strategy = "ascending",
  },
}

M.config = function(_, opts)
  opts.extensions = merge(opts.extensions, {
    media_files = {
      filetypes = { "png", "webp", "jpg", "jpeg" },
      find_cmd = "rg",
    },
  })

  local telescope = require("telescope")
  telescope.setup(opts)
  telescope.load_extension("import")
  telescope.load_extension("lazy")
  telescope.load_extension("package_info")
end

return M
