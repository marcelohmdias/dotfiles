local M = { gh('obsidian-nvim/obsidian.nvim') }

M.cmd = 'Obsidian'
M.event = {
  'BufReadPre ' .. vim.fn.expand('~') .. '/vaults/brainforge/*.md',
  'BufNewFile ' .. vim.fn.expand('~') .. '/vaults/brainforge/*.md',
}

function M.config(_, opts)
  require('obsidian').setup(opts)
end

---@module 'obsidian'
---@type obsidian.config
M.opts = {
  daily_notes = {
    folder = "daily",
    date_format = "YYYY-MM-DD",
    template = "templates/daily_template.md",
  },
  completion = {
    blink = true,
  },
  legacy_commands = false,
  new_notes_location = "notes_subdir",
  notes_subdir = "zettels",
  picker = {
    name = 'snacks.pick',
  },
  templates = {
    subdir = "templates",
    date_format = "YYYY-MM-DD",
    time_format = "HH:mm",
  },
  ui = {
    enable = false,
  },
  workspaces = {
    {
      name = "Brainforge",
      path = "~/Vaults/brainforge",
    },
  },
}

M.version = '*'

return M
