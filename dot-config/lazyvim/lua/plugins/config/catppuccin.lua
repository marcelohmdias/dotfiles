local C = require("catppuccin.palettes").get_palette()

local M = { "catppuccin/nvim" }

M.name = "catppuccin"

---@class CatppuccinOptions
M.opts = {
  flavour = "frappe",
  highlight_overrides = {
    all = function()
      local is_transparent = vim.g.transparent_enabled
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
  float = {
    solid = false,
    transparent = vim.g.transparent_enabled,
  },
  integrations = {
    copilot_vim = true,
    dap = true,
    dap_ui = true,
    diffview = true,
    dropbar = { enabled = true, color_mode = false },
    fidget = true,
    grug_far = true,
    mini = { enabled = true },
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = { "italic" },
        hints = { "italic" },
        warnings = { "italic" },
        information = { "italic" },
        ok = { "italic" },
      },
      inlay_hints = {
        background = true,
      },
    },
    neogit = true,
    octo = true,
    overseer = true,
    render_markdown = true,
    semantic_tokens = true,
    snacks = { enabled = true },
    treesitter_context = true,
    ufo = true,
  },
  no_italic = false,
  no_bold = false,
  styles = {
    comments = { "italic" },
  },
  term_colors = false,
  transparent_background = vim.g.transparent_enabled,
}

return M
