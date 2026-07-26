local icons = require('core.icons')

local M = { gh('folke/which-key.nvim') }

M.event = 'VeryLazy'

M.keys = {
  {
    '<leader>?',
    function()
      require('which-key').show({ global = false })
    end,
    desc = 'Buffer Keymaps (which-key)',
  },
  {
    '<c-w><space>',
    function()
      require('which-key').show({ keys = '<c-w>', loop = true })
    end,
    desc = 'Window Hydra Mode (which-key)',
  },
}

function M.config()
  local wk = require('which-key')
  wk.setup({ preset = 'classic' })

  require('which-key.presets').classic.win.border = vim.g.transparency_enabled and 'rounded' or 'none'

  -- Apply icon rules post-setup (vim.tbl_deep_extend in wk.setup destroys arrays)
  require('which-key.config').options.icons.rules = {
    { pattern = 'minipack', icon = icons.misc.stack, color = 'purple' },
    { pattern = 'diff', cat = 'filetype', name = 'git' },
    { pattern = 'mark', icon = icons.misc.mark, color = 'red' },
    { pattern = 'goto', icon = icons.misc.go_to, color = 'blue' },
    { pattern = 'go to', icon = icons.misc.go_to, color = 'blue' },
    { pattern = 'package', icon = icons.kinds.Module, color = 'orange' },
    { pattern = 'precognition', icon = icons.misc.robot, color = 'purple' },
    { pattern = 'project', icon = icons.misc.project, color = 'azure' },
    { pattern = 'yazi', icon = icons.misc.duck, color = 'yellow' },
  }

  wk.add({
    mode = { 'n', 'x' },
    { '<leader><tab>', group = 'tabs' },
    { '<leader>M', group = 'MiniPack' },
    { '<leader>I', group = 'PackageInfo' },
    { '<leader>a', group = 'ai' },
    {
      '<leader>b',
      group = 'buffer',
      expand = function()
        return require('which-key.extras').expand.buf()
      end,
    },
    { '<leader>c', group = 'code' },
    { '<leader>d', group = 'debug' },
    { '<leader>f', group = 'file/find' },
    { '<leader>g', group = 'git' },
    { '<leader>gh', group = 'hunks' },
    { '<leader>q', group = 'quit/session' },
    { '<leader>r', group = 'refactor' },
    { '<leader>R', group = 'rest' },
    { '<leader>s', group = 'search' },
    { '<leader>u', group = 'ui' },
    {
      '<leader>w',
      group = 'windows',
      proxy = '<c-w>',
      expand = function()
        return require('which-key.extras').expand.win()
      end,
    },
    { '<leader>x', group = 'diagnostics/quickfix' },
    { '[', group = 'prev' },
    { ']', group = 'next' },
    { 'g', group = 'goto' },
    { 'go', group = 'operators' },
    { 'gs', group = 'surround' },
    { 'gx', desc = 'Open with system app' },
    { 'z', group = 'fold' },
  })
end

return M
