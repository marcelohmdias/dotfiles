-- Global variables (vim.g)
local g = vim.g

-- Leader keys (must be set before any keymap or plugin)
g.mapleader = ' '
g.maplocalleader = '\\'

-- UI
g.transparency_enabled = true

-- AI
g.claudecode_enabled = false
g.copilot_enabled = true
g.opencode_enabled = true

-- LSP
g.docker_enabled = true
g.tsc_enabled = true

-- Markdown
g.markdown_recommended_style = 0

-- Plugins
g.wakatime_no_statusline = true

if not g.transparency_enabled then
  g.border = 'none'
  g.winblend = vim.o.pumblend
else
  g.border = 'rounded'
  g.winblend = 0
end

-- Disable builtin plugins
local disabled_builtins = {
  'gzip',
  'matchit',
  'matchparen',
  'netrwPlugin',
  'sql_completion',
  'tarPlugin',
  'tohtml',
  'tutor',
  'zipPlugin',
}

-- Disable SQL omnicompletion defaults to avoid conflict with blink.cmp
g.omni_sql_no_default_maps = 1

for _, plugin in ipairs(disabled_builtins) do
  vim.g['loaded_' .. plugin] = 1
end
