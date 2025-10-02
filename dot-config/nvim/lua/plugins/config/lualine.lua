local C = require("catppuccin.palettes").get_palette()
local icons = require("config.icons")

local M = { "nvim-lualine/lualine.nvim" }

--- TODO: Move icons to icon file
function M.opts(_, opts)
  local function not_empty()
    return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
  end

  local function branch()
    return {
      "branch",
      icon = string.gsub(icons.git.branch, "%s+", ""),
      padding = { left = 2, right = 1 },
    }
  end

  local function copilot()
    local copilotIcons = {
      Error = { " ", "DiagnosticError" },
      Inactive = { " ", "MsgArea" },
      Warning = { " ", "DiagnosticWarn" },
      Normal = { LazyVim.config.icons.kinds.Copilot, "Special" },
    }

    return {
      function()
        local status = require("sidekick.status").get()
        return status and vim.tbl_get(copilotIcons, status.kind, 1)
      end,
      color = function()
        local status = require("sidekick.status").get()
        local hl = status
          and (status.busy and "DiagnosticWarn" or vim.tbl_get(copilotIcons, status.kind, 2))
        return { fg = Snacks.util.color(hl) }
      end,
      cond = function()
        return require("sidekick.status").get() ~= nil
      end,
    }
  end

  local function cursor_position()
    return {
      function()
        local line = vim.fn.line(".")
        local col = vim.fn.virtcol(".")
        return "Ln:" .. line .. "  Col:" .. col
      end,
      color = { fg = C.overlay2 },
      padding = 1,
    }
  end

  local function dap()
    return {
      function()
        return icons.dap.debug .. require("dap").status()
      end,
      color = function()
        return {
          fg = Snacks.util.color("Debug"),
        }
      end,
      cond = function()
        return package.loaded["dap"] and require("dap").status() ~= ""
      end,
    }
  end

  local function diagnostics()
    return {
      "diagnostics",
      symbols = {
        error = icons.alerts.error,
        warn = icons.alerts.warn,
        info = icons.alerts.info,
        hint = icons.alerts.hint,
      },
    }
  end

  local function diff()
    return {
      "diff",
      padding = { left = 0, right = 1 },
      symbols = {
        added = icons.git.added,
        modified = icons.git.modified,
        removed = icons.git.removed,
      },
    }
  end

  local function dir_name()
    return {
      function()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
      end,
      cond = not_empty,
      icon = {
        icons.misc.folder,
        align = "left",
        padding = { left = 0, right = 1 },
      },
    }
  end

  local function encoding()
    return {
      "encoding",
      color = { fg = C.overlay2 },
      cond = not_empty,
      fmt = string.upper,
      padding = 1,
    }
  end

  local function file_format()
    return {
      "fileformat",
      color = { fg = C.overlay2 },
      cond = not_empty,
      padding = 1,
      symbols = { unix = "LF", dos = "CRLF", mac = "CR" },
    }
  end

  local function file_icon()
    return {
      "filetype",
      color = { fg = C.overlay2 },
      icon_only = true,
      cond = not_empty,
      padding = { left = 1, right = 0 },
      separator = "",
    }
  end

  local function file_name()
    return {
      "filename",
      cond = not_empty,
      padding = 0,
      symbols = {
        modified = " ",
        readonly = " ",
        unnamed = " ",
        newfile = " ",
      },
    }
  end

  local function file_size()
    return {
      "filesize",
      color = { fg = C.overlay2 },
      cond = not_empty,
      padding = 1,
    }
  end

  local function file_type()
    return {
      function()
        return icons.kinds.Namespace .. vim.bo.filetype
      end,
      color = { fg = C.overlay2 },
      cond = not_empty,
      padding = 1,
    }
  end

  local function indentation()
    return {
      function()
        local opt = vim.opt

        if not opt.expandtab:get() then
          return "Tabs:" .. opt.tabstop:get()
        end

        local size = opt.shiftwidth:get()
        if size == 0 then
          size = opt.tabstop:get()
        end

        return "Spaces:" .. size
      end,
      color = { fg = C.overlay2 },
      cond = not_empty,
      padding = 1,
    }
  end

  local function lazy_status()
    return {
      require("lazy.status").updates,
      color = function()
        return {
          fg = Snacks.util.color("Special"),
        }
      end,
      cond = require("lazy.status").has_updates,
    }
  end

  local function lsp_info()
    return {
      function()
        local msg = "No Active Lsp"
        local clients = vim.lsp.get_clients()

        if next(clients) == nil then
          return msg
        end

        for _, client in ipairs(clients) do
          if client.name ~= "null-ls" and client.name ~= "copilot" then
            return (vim.o.columns > 100 and client.name) or "Lsp"
          end
        end

        return msg
      end,
      color = { fg = C.overlay2 },
      cond = not_empty,
      icon = icons.misc.lsp,
      padding = { left = 1, right = 2 },
    }
  end

  local function mode_icon()
    return string.gsub(icons.misc.stack, "%s+", "")
  end

  local function noice_mode()
    local noice_status = require("noice").api.status.mode
    return {
      function()
        ---@diagnostic disable-next-line: undefined-field
        return noice_status.get()
      end,
      color = function()
        return {
          fg = Snacks.util.color("Constant"),
        }
      end,
      cond = function()
        ---@diagnostic disable-next-line: undefined-field
        return package.loaded["noice"] and noice_status.has()
      end,
    }
  end

  opts.options = vim.tbl_deep_extend("force", opts.options, {
    component_separators = "",
    section_separators = "",
  })

  opts.sections.lualine_a = { mode_icon }

  opts.sections.lualine_b = { "mode" }

  opts.sections.lualine_c = { branch(), diff(), file_icon(), file_name(), diagnostics() }

  opts.sections.lualine_x = {
    Snacks.profiler.status(),
    noice_mode(),
    lazy_status(),
    copilot(),
    dap(),
    file_size(),
    cursor_position(),
    indentation(),
    encoding(),
    file_format(),
    file_type(),
    lsp_info(),
  }

  opts.sections.lualine_y = { dir_name() }

  opts.sections.lualine_z = {}
end

return M
