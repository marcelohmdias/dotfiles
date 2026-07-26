local M = { gh('vuki656/package-info.nvim') }

M.dependencies = { gh('MunifTanjim/nui.nvim') }
M.ft = { 'json' }

function M.config(_, opts)
  require('package-info').setup(opts)
end

M.opts = function()
  local ok, palette = pcall(require, 'catppuccin.palettes')
  local C = ok and palette.get_palette() or {}
  local icons = require('core.icons')

  return {
    autostart = true,
    hide_unstable_versions = false,
    hide_up_to_date = true,
    highlights = {
      invalid = { fg = C.red },
      outdated = { fg = C.peach },
      up_to_date = { fg = C.teal },
    },
    icons = {
      enable = true,
      style = {
        invalid = icons.alerts.error,
        outdated = icons.git.removed,
        up_to_date = icons.git.staged,
      },
    },
    package_manager = 'npm',
  }
end

M.keys = {
  { '<leader>Id', function() require('package-info').delete() end,         desc = 'Delete package' },
  { '<leader>Ih', function() require('package-info').hide() end,           desc = 'Hide package info' },
  { '<leader>Ii', function() require('package-info').install() end,        desc = 'Install package' },
  { '<leader>In', function() require('package-info').toggle() end,         desc = 'Toggle package info' },
  { '<leader>Is', function() require('package-info').show() end,           desc = 'Show package info' },
  { '<leader>Iu', function() require('package-info').update() end,         desc = 'Update package' },
  { '<leader>Iv', function() require('package-info').change_version() end, desc = 'Change package version' },
}

return M
