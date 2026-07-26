local M = { gh('christoomey/vim-tmux-navigator') }

M.cmd = {
  'TmuxNavigateDown',
  'TmuxNavigateLeft',
  'TmuxNavigateRight',
  'TmuxNavigateUp',
}

-- stylua: ignore
M.keys = {
  { '<C-h>', cmd('TmuxNavigateLeft'),  desc = 'Navigate Left' },
  { '<C-j>', cmd('TmuxNavigateDown'),  desc = 'Navigate Down' },
  { '<C-k>', cmd('TmuxNavigateUp'),    desc = 'Navigate Up' },
  { '<C-l>', cmd('TmuxNavigateRight'), desc = 'Navigate Right' },
}

return M
