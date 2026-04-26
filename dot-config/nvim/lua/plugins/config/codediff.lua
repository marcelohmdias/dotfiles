local M = { gh('esmuellert/codediff.nvim') }

M.cmd = 'CodeDiff'

-- stylua: ignore
M.keys = {
  { '<leader>gd', cmd('CodeDiff'),            desc = 'Diff Explorer' },
  { '<leader>gf', cmd('CodeDiff file HEAD'),  desc = 'Diff File (HEAD)' },
  { '<leader>gF', cmd('CodeDiff history'),    desc = 'File History' },
}

---@module 'codediff'
---@type codediff.Config
M.opts = {}

return M
