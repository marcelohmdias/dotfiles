local M = { "nvzone/timerly" }

M.cmd = "TimerlyToggle"

M.dependencies = {
  { "nvzone/volt", event = "VeryLazy" },
}

M.event = "VeryLazy"

M.opts = {}

return M
