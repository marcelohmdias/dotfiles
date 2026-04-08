local M = { "dnlhc/glance.nvim" }

M.cmd = "Glance"

M.event = "LazyFile"

M.keys = {
  { "gGd", "<Cmd>Glance definitions<CR>", desc = "Go to definition" },
  { "gGi", "<Cmd>Glance implementations<CR>", desc = "Go to implementation" },
  { "gGr", "<Cmd>Glance references<CR>", desc = "Go to references" },
  { "gGt", "<Cmd>Glance type_definitions<CR>", desc = "Go to type definition" },
}

--- @class GlanceOpts
M.opts = {
  border = {
    enable = vim.g.transparent_enabled,
  },
}

return M
