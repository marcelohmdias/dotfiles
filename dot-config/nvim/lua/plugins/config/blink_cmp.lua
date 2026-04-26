local icons = require('core.icons')

local M = { gh('saghen/blink.cmp') }

M.dependencies = {
  gh('fang2hou/blink-copilot'),
  gh('Kaiser-Yang/blink-cmp-git'),
  gh('rafamadriz/friendly-snippets'),
  gh('saghen/blink.download'),
  gh('xzbdmw/colorful-menu.nvim'),
}
M.event = { 'InsertEnter', 'CmdlineEnter' }

---@module 'blink.cmp'
---@type blink.cmp.Config
M.opts = {
  appearance = {
    nerd_font_variant = 'mono',
  },
  cmdline = {
    enabled = true,
    completion = {
      ghost_text = { enabled = true },
      list = { selection = { preselect = false } },
      menu = {
        auto_show = function(ctx)
          return vim.fn.getcmdtype() == ':'
        end,
      },
    },
    keymap = {
      preset = 'cmdline',
      ['<Left>'] = false,
      ['<Right>'] = false,
    },
  },
  completion = {
    accept = {
      auto_brackets = { enabled = true },
    },
    documentation = {
      auto_show = false,
      window = {
        border = vim.g.border,
        scrollbar = false,
      },
    },
    menu = {
      border = vim.g.border,
      draw = {
        columns = {
          { 'kind_icon', 'kind_icon_color' },
          { 'label', 'label_description' },
          { 'kind' },
          { 'source_name' },
        },
        components = {
          label = {
            highlight = function(ctx)
              return require('colorful-menu').blink_components_highlight(ctx)
            end,
            text = function(ctx)
              return require('colorful-menu').blink_components_text(ctx)
            end,
            width = { fill = true, max = 60 },
          },
          kind_icon_color = {
            highlight = function(ctx)
              local hlc = require('nvim-highlight-colors')
              local color = hlc.format(ctx.item.documentation, { kind = ctx.kind })
              if color and color.abbr_hl_group then
                return color.abbr_hl_group
              end
            end,
            text = function(ctx)
              local hlc = require('nvim-highlight-colors')
              local color = hlc.format(ctx.item.documentation, { kind = ctx.kind })
              if color and color.virtual_text then
                return color.virtual_text
              end
              return ''
            end,
          },
        },
        gap = 2,
        treesitter = { 'lsp' },
      },
      min_width = 20,
      scrollbar = false,
      winblend = vim.g.winblend,
    },
  },
  keymap = {
    preset = 'enter',
    ['<C-y>'] = { 'select_and_accept' },
  },
  signature = {
    enabled = true,
    window = { border = vim.g.border },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot', 'markdown' },
    per_filetype = {
      gitcommit = { inherit_defaults = true, 'git' },
      lua = { inherit_defaults = true, 'lazydev' },
      markdown = { inherit_defaults = true, 'git' },
    },
    providers = {
      copilot = {
        name = 'copilot',
        module = 'blink-copilot',
        async = true,
        opts = {
          kind_icon = icons.kinds.Copilot,
          max_completions = 3,
        },
        score_offset = 100,
      },
      git = {
        name = 'Git',
        module = 'blink-cmp-git',
        score_offset = 100,
      },
      lazydev = {
        name = 'LazyDev',
        module = 'lazydev.integrations.blink',
        score_offset = 100,
      },
      lsp = {
        name = 'LSP',
        module = 'blink.cmp.sources.lsp',
        fallbacks = { 'buffer' },
        score_offset = 0,
      },
      markdown = {
        name = 'RenderMarkdown',
        module = 'render-markdown.integ.blink',
      },
    },
  },
}

M.version = '*'

return M
