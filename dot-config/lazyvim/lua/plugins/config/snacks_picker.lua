local icons = require("config.icons")
local utils = require("config.utils")

local M = { "folke/snacks.nvim" }

M.keys = {
  {
    "<leader><space>",
    function()
      Snacks.picker.smart({ layout = { preset = "vscode" } })
    end,
    desc = "Smart Find Files",
  },
  {
    "<leader>sz",
    function()
      Snacks.picker.zoxide({
        layout = { preset = "vscode" },
      })
    end,
    desc = "Zoxide",
  },
  {
    "<leader>Cc",
    function()
      Snacks.picker.files({
        cwd = "~/.config/nvim/lua/config/",
        layout = { preset = "vscode" },
      })
    end,
    desc = "Config Files",
  },
  {
    "<leader>Ci",
    function()
      Snacks.picker.files({
        cwd = "~/.config/nvim/lua/plugins/",
        exclude = { "config" },
        layout = { preset = "vscode" },
      })
    end,
    desc = "Plugins Config Import",
  },
  {
    "<leader>Cp",
    function()
      Snacks.picker.files({
        cwd = "~/.config/nvim/lua/plugins/config/",
        layout = { preset = "vscode" },
      })
    end,
    desc = "Plugins Config",
  },
}

---@module "snacks"
---@param opts snacks.Config
function M.opts(_, opts)
  local function get_dynamic_preset()
    return vim.o.columns >= 140 and "default" or "vertical"
  end

  ---@class snacks.picker.Config
  local picker = {
    ---@diagnostic disable-next-line: missing-fields
    icons = {
      files = {
        enabled = true,
      },
      diagnostic = icons.alerts,
      git = icons.git,
      kinds = icons.kinds,
    },
    layouts = {
      default = {
        layout = {
          border = "none",
        },
      },
      sidebar = {
        layout = {
          width = 45,
          min_width = 45,
          position = "left",
          border = "none",
        },
      },
      vscode = {
        layout = {
          backdrop = false,
          row = 1,
          width = 0.4,
          min_width = 80,
          height = 0.4,
          border = "none",
          box = "vertical",
          {
            win = "input",
            height = 1,
            border = "rounded",
            title = "{title} {live} {flags}",
            title_pos = "center",
          },
          { win = "list", border = "rounded" },
          { win = "preview", title = "{preview}", border = "rounded" },
        },
      },
    },
    prompt = icons.misc.telescope,
    sources = {
      explorer = {
        auto_close = true,
        layout = { preview = { main = true, enabled = false } },
      },
      files = {
        layout = { preset = get_dynamic_preset },
      },
      lsp_symbols = {
        layout = { preset = "vscode", preview = "main" },
      },
      lsp_workspace_symbols = {
        layout = { preset = "vscode", preview = "main" },
      },
      recent = {
        layout = { preset = get_dynamic_preset },
      },
    },
    ui_select = true,
  }

  opts.picker = utils.merge(opts.picker, picker)

  return opts
end

return M
