local M = { gh('nvim-mini/mini.sessions') }

M.lazy = false

-- stylua: ignore
M.keys = {
  { '<leader>qs', function() MiniSessions.read() end, desc = 'Restore Session' },
  { '<leader>qS', function() MiniSessions.select('read') end, desc = 'Select Session' },
  { '<leader>ql', function() MiniSessions.read(MiniSessions.get_latest()) end, desc = 'Restore Last Session' },
  { '<leader>qw', function() MiniSessions.write() end, desc = 'Write Session' },
  { '<leader>qd', function() MiniSessions.delete() end, desc = 'Delete Session' },
}

---@module 'mini.sessions'
---@type MiniSessions.config
M.opts = {
  autoread = false,
  autowrite = true,
  hooks = {
    pre = {
      -- Auto-save current session on write (cwd-based name).
      -- Ensures a session exists for the dashboard "Restore Session" action,
      -- matching persistence.nvim's auto-save behavior.
      write = nil,
    },
  },
}

M.config = function(_, opts)
  require('mini.sessions').setup(opts)

  -- Auto-save session on exit (like persistence.nvim).
  -- Uses cwd as session name so each project gets its own session.
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = vim.api.nvim_create_augroup('MiniSessions_autosave', { clear = true }),
    callback = function()
      -- Only save if there are real file buffers open
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '' and vim.api.nvim_buf_get_name(buf) ~= '' then
          local name = vim.fn.fnamemodify(vim.uv.cwd() or '', ':t')
          if name ~= '' then
            MiniSessions.write(name, { force = true })
          end
          return
        end
      end
    end,
  })
end

return M
