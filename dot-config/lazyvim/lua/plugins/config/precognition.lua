local M = { "tris203/precognition.nvim" }

M.enabled = vim.g.precognition

M.event = "LazyFile"

function M.keys()
  local precog = require("precognition")

  require("which-key").add({
    { "<leader>uP", precog.toggle, desc = "Toggle Precognition" },
    { "<leader>B", precog.peek, desc = "Precognition" },
  })
end

---@type Precognition.PartialConfig
M.opts = {
  startVisible = false,
}

return M
