local M = { "nvzone/typr" }

M.cmd = "TyprStats"

M.dependencies = {
  { "nvzone/volt", event = "VeryLazy" },
}

M.event = "VeryLazy"

M.opts = {}

return M
