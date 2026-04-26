local transparent = vim.g.transparency_enabled

-- Catppuccin colorscheme configuration
require('catppuccin').setup({
  default_integrations = false,
  flavour = 'frappe',
  float = {
    solid = false,
    transparent = transparent,
  },
  highlight_overrides = {
    all = function()
      local C = require("catppuccin.palettes").get_palette()
      local is_transparent = vim.g.transparency_enabled
      return {
        BlinkCmpMenu = is_transparent and { link = "NormalFloat" } or {},
        BlinkCmpMenuBorder = is_transparent and { link = "FloatBorder" } or {},
        BlinkCmpMenuSelection = { bg = C.blue, fg = C.base },

        CodewindowBorder = { fg = C.surface1 },
        CodewindowUnderline = { sp = C.overlay0, underline = true },

        SnacksBackdrop = is_transparent and { link = "NormalFloat" } or {},
        SnacksDashboardIcon = { fg = C.lavender, bold = true },
      }
    end,
  },

  integrations = {
    blink_cmp = { enabled = true, style = 'bordered' },
    blink_indent = true,
    blink_pairs = true,
    dap = true,
    dap_ui = true,

    dropbar = { enabled = true, color_mode = true },
    flash = true,
    gitsigns = true,
    grug_far = true,
    lsp_trouble = true,
    mason = true,
    markdown = true,
    mini = { enabled = true, indentscope_color = 'overlay2' },
    neogit = true,
    neotest = true,
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = { 'italic' },
        hints = { 'italic' },
        warnings = { 'italic' },
        information = { 'italic' },
        ok = { 'italic' },
      },
      inlay_hints = {
        background = true,
      },
    },
    noice = true,
    octo = true,
    render_markdown = true,
    snacks = { enabled = true },
    treesitter = true,
    treesitter_context = true,
    which_key = true,
  },
  lsp_styles = {
    underlines = {
      errors = { 'undercurl' },
      hints = { 'undercurl' },
      warnings = { 'undercurl' },
      information = { 'undercurl' },
    },
  },
  no_italic = false,
  no_bold = false,
  styles = {
    comments = { 'italic' },
  },
  term_colors = true,
  transparent_background = vim.g.transparency_enabled,
})

local ok, _ = pcall(vim.cmd.colorscheme, 'catppuccin-frappe')
if not ok then
  vim.cmd.colorscheme('habamax')
end
