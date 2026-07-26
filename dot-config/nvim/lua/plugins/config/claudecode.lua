local M = { gh('coder/claudecode.nvim') }

M.enabled = vim.g.claudecode_enabled

M.dependencies = {
  gh('folke/snacks.nvim'),
}

-- stylua: ignore
M.cmd = {
  'ClaudeCode',
  'ClaudeCodeFocus',
  'ClaudeCodeSelectModel',
  'ClaudeCodeAdd',
  'ClaudeCodeSend',
  'ClaudeCodeTreeAdd',
  'ClaudeCodeStatus',
  'ClaudeCodeStart',
  'ClaudeCodeStop',
  'ClaudeCodeOpen',
  'ClaudeCodeClose',
  'ClaudeCodeDiffAccept',
  'ClaudeCodeDiffDeny',
  'ClaudeCodeCloseAllDiffs',
}

-- stylua: ignore
M.keys = {
  { '<leader>ac', '<cmd>ClaudeCode<cr>',              desc = 'Toggle Claude' },
  { '<leader>af', '<cmd>ClaudeCodeFocus<cr>',          desc = 'Focus Claude' },
  { '<leader>ar', '<cmd>ClaudeCode --resume<cr>',      desc = 'Resume Claude' },
  { '<leader>aC', '<cmd>ClaudeCode --continue<cr>',    desc = 'Continue Claude' },
  { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>',    desc = 'Select Claude Model' },
  { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>',          desc = 'Add Current Buffer' },
  { '<leader>aS', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send Selection to Claude' },
  { '<leader>aA', '<cmd>ClaudeCodeDiffAccept<cr>',     desc = 'Accept Diff' },
  { '<leader>aD', '<cmd>ClaudeCodeCloseAllDiffs<cr>',  desc = 'Close All Diffs' },
}

M.opts = {
  terminal = {
    snacks_win_opts = {
      position = 'float',
      width = 0.9,
      height = 0.9,
      border = vim.g.border,
      keys = {
        claude_hide = {
          '<leader>af',
          function(self)
            self:hide()
          end,
          mode = 't',
          desc = 'Hide',
        },
      },
    },
  },
}

M.version = '*'

return M
