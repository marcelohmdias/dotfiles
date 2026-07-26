local M = { gh('folke/snacks.nvim') }

---@type snacks.Config
M.opts = {
  image = {
    doc = { enabled = true },
    math = { enabled = true },
  },
}

return M
