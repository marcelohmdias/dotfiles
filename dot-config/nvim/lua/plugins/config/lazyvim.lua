local icons = require("config.icons")

local M = { "LazyVim/LazyVim" }

---@class LazyVimConfig
M.opts = {
  colorscheme = "catppuccin",
  icons = {
    misc = icons.misc,

    dap = {
      Stopped = { icons.dap.stopped, "DiagnosticWarn", "DapStoppedLine" },
      Breakpoint = icons.dap.breakpoint,
      BreakpointCondition = icons.alerts.question,
      BreakpointRejected = { icons.alerts.attention, "DiagnosticError" },
      LogPoint = icons.dap.logpoint,
    },

    diagnostics = {
      Error = icons.alerts.error,
      Warn = icons.alerts.warn,
      Hint = icons.alerts.hint,
      Info = icons.alerts.info,
    },

    git = {
      added = icons.git.added,
      modified = icons.git.modified,
      removed = icons.git.removed,
    },

    kinds = icons.kinds,
  },
  news = {
    lazyvim = true,
    neovim = true,
  },
}

M.version = false

return M
