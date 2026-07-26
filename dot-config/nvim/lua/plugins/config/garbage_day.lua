local M = { gh('Zeioth/garbage-day.nvim') }

M.event = 'LspAttach'

function M.config(_, opts)
  require('garbage-day').setup(opts)
end

---@type table
M.opts = {
  grace_period = 60 * 10,
}

return M
