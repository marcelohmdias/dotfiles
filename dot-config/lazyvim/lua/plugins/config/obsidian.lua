local M = { "obsidian-nvim/obsidian.nvim" }

M.cmd = {
  "ObsidianOpen",
  "ObsidianNew",
  "ObsidianQuickSwitch",
  "ObsidianFollowLink",
  "ObsidianBacklinks",
  "ObsidianToday",
  "ObsidianYesterday",
  "ObsidianTemplate",
  "ObsidianSearch",
  "ObsidianLink",
  "ObsidianLinkNew",
}

M.dependencies = {
  "nvim-lua/plenary.nvim",
  "nvim-treesitter/nvim-treesitter",
}

M.ft = "markdown"

M.opts = {
  daily_notes = {
    folder = "daily",
    date_format = "YYYY-MM-DD",
    template = "templates/daily_template.md",
  },
  new_notes_location = "notes_subdir",
  notes_subdir = "zettels",
  picker = {
    name = "snacks.pick",
  },
  templates = {
    subdir = "templates",
    date_format = "YYYY-MM-DD",
    time_format = "HH:mm",
  },
  ui = {
    enabled = false,
  },
  workspaces = {
    {
      name = "Brainforge",
      path = "~/Vaults/brainforge",
    },
  },
}

return M
