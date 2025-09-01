local M = { "saghen/blink.cmp" }

M.dependencies = {
  { "xzbdmw/colorful-menu.nvim", event = "InsertEnter" },
}

M.event = "InsertEnter"

---@class blink.cmp.Config
M.opts = {
  completion = {
    documentation = {
      auto_show = false,
      window = {
        border = vim.g.modal_border,
        scrollbar = false,
      },
    },
    menu = {
      border = vim.g.modal_border,
      draw = {
        columns = {
          { "kind_icon" },
          { "label", "label_description" },
          { "kind" },
          { "source_name" },
        },
        components = {
          label = {
            highlight = function(ctx)
              return require("colorful-menu").blink_components_highlight(ctx)
            end,
            text = function(ctx)
              return require("colorful-menu").blink_components_text(ctx)
            end,
            width = { fill = true, max = 60 },
          },
        },
        gap = 2,
      },
      min_width = 20,
      scrollbar = false,
      winblend = vim.g.winblend,
    },
  },
  signature = {
    enabled = true,
    window = { border = vim.g.modal_border },
  },
  sources = {
    default = { "markdown" },
    providers = {
      markdown = { name = "RenderMarkdown", module = "render-markdown.integ.blink" },
    },
  },
}

return M
