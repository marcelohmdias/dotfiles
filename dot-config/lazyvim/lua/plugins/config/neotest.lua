local M = { "nvim-neotest/neotest" }

M.dependencies = {
  "nvim-neotest/neotest-jest",
  "marilari88/neotest-vitest",
}

M.opts = {
  adapters = {
    ["neotest-jest"] = {},
    ["neotest-vitest"] = {},
  },
}

return M
