local M = { gh('jmbuhr/otter.nvim') }

M.ft = { 'markdown', 'quarto' }

---@module 'otter'
---@type otter.config.cfg
M.opts = {
  buffers = {
    set_filetype = true,
    write_to_disk = false,
  },
  handle_leading_whitespace = true,
  lsp = {
    diagnostic_update_events = { 'BufWritePost', 'InsertLeave', 'TextChanged' },
  },
  verbose = {
    no_code_found = false,
  },
}

return M
