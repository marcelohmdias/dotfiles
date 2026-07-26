local M = {}

_G.MiniPack = {} ---@diagnostic disable-line: missing-fields

function M.setup()
  vim.loader.enable()

  -- Shim lazy.nvim modules (lazy-loaded on first require)
  package.preload['lazy.stats'] = function()
    return require('core.pkg.status')
  end
  package.preload['lazy.status'] = function()
    return require('core.pkg.status')
  end

  -- Capture startup time at UIEnter (must register before event fires)
  vim.api.nvim_create_autocmd('UIEnter', {
    once = true,
    callback = function()
      require('core.pkg.status').on_ui_enter()
    end,
  })

  require('config.globals')

  local utils = require('core.utils')
  MiniPack.formatexpr = utils.formatexpr
  MiniPack.statuscolumn = utils.statuscolumn
  MiniPack.root = utils.root
  MiniPack.root_git = utils.root_git

  require('config.options')

  local sources = require('core.pkg.sources')
  local mappers = require('core.mappers')

  -- Global helpers
  _G.gh = sources.gh
  _G.cb = sources.cb
  _G.map = mappers.map
  _G.cmd = mappers.cmd
  _G.autocmd = mappers.autocmd

  -- Foundation plugins (outside MiniPack)
  local foundation = {
    { src = gh('nvim-mini/mini.misc'),  name = 'mini.misc' },
    { src = gh('nvim-mini/mini.icons'), name = 'mini.icons' },
    { src = gh('folke/snacks.nvim'),    name = 'snacks.nvim', version = 'main' },
    { src = gh('catppuccin/nvim'),      name = 'catppuccin' },
  }

  local foundation_missing = {} ---@type table[]
  local fnd_opt = vim.fn.stdpath('data') .. '/site/pack/core/opt/'
  for _, spec in ipairs(foundation) do
    if not vim.uv.fs_stat(fnd_opt .. spec.name) then
      foundation_missing[#foundation_missing + 1] = spec
    else
      vim.cmd.packadd(spec.name)
    end
  end

  if #foundation_missing > 0 then
    vim.pack.add(foundation_missing)
  end

  -- Init mini.misc
  require('mini.misc').setup()
  MiniMisc.setup_auto_root()
  MiniMisc.setup_restore_cursor()
  MiniMisc.setup_termbg_sync()

  -- Init mini.icons
  require('mini.icons').setup({
    file = {
      ['.keep'] = { lyph = '󰊢 ', hl = 'MiniIconsGrey' },
      ['devcontainer.json'] = { glyph = ' ', hl = 'MiniIconsAzure' },
      ['vite.config.ts'] = { glyph = ' ', hl = 'MiniIconsAzure' },
    },
    filetype = {
      dotenv = { glyph = ' ', hl = 'MiniIconsYellow' },
    },
  })
  MiniIcons.mock_nvim_web_devicons()
  MiniIcons.tweak_lsp_kind()

  -- Root detection cache
  utils.root_setup()

  -- Pre-plugin config
  require('config.colorscheme')
  require('config.autocmds')
  require('config.diagnostics')

  -- MiniPack loads all other plugins
  require('core.pkg').setup({ import = 'plugins', confirm = true, minimum_release_age = '7d' })

  -- Expose update check for statusline (lazy to avoid loading ui module at boot)
  MiniPack.pending_count = function()
    return require('core.pkg.ui').pending_count() ---@diagnostic disable-line: return-type-mismatch
  end

  -- Post-plugin config
  require('config.keymaps')
  require('config.lsp')
end

return M
