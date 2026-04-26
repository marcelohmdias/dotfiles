local M = { gh('pwntester/octo.nvim') }

M.cmd = 'Octo'

M.config = function(_, opts)
  vim.treesitter.language.register('markdown', 'octo')
  require('octo').setup(opts)

  -- Keep octo windows in sessions
  vim.api.nvim_create_autocmd('ExitPre', {
    group = vim.api.nvim_create_augroup('octo_exit_pre', { clear = true }),
    callback = function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == 'octo' then
          vim.bo[buf].buftype = ''
        end
      end
    end,
  })
end

M.event = 'BufReadCmd octo://*'

-- stylua: ignore
M.keys = {
  { '<leader>gi', cmd('Octo issue list'), desc = 'List Issues (Octo)' },
  { '<leader>gI', cmd('Octo issue search'), desc = 'Search Issues (Octo)' },
  { '<leader>gp', cmd('Octo pr list'), desc = 'List PRs (Octo)' },
  { '<leader>gP', cmd('Octo pr search'), desc = 'Search PRs (Octo)' },
  { '<leader>gr', cmd('Octo repo list'), desc = 'List Repos (Octo)' },
  { '<leader>gS', cmd('Octo search'), desc = 'Search (Octo)' },
  { '<localleader>a', '', desc = '+assignee (Octo)', ft = 'octo' },
  { '<localleader>c', '', desc = '+comment/code (Octo)', ft = 'octo' },
  { '<localleader>l', '', desc = '+label (Octo)', ft = 'octo' },
  { '<localleader>i', '', desc = '+issue (Octo)', ft = 'octo' },
  { '<localleader>r', '', desc = '+react (Octo)', ft = 'octo' },
  { '<localleader>p', '', desc = '+pr (Octo)', ft = 'octo' },
  { '<localleader>pr', '', desc = '+rebase (Octo)', ft = 'octo' },
  { '<localleader>ps', '', desc = '+squash (Octo)', ft = 'octo' },
  { '<localleader>v', '', desc = '+review (Octo)', ft = 'octo' },
  { '<localleader>g', '', desc = '+goto_issue (Octo)', ft = 'octo' },
  { '@', '@<C-x><C-o>', mode = 'i', ft = 'octo', silent = true },
  { '#', '#<C-x><C-o>', mode = 'i', ft = 'octo', silent = true },
}

---@module 'octo'
---@type OctoConfig
M.opts = {
  default_merge_method = 'squash',
  default_to_projects_v2 = true,
  enable_builtin = true,
  picker = 'snacks',
}

return M
