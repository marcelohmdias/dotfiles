-- Editor autocmds (no plugin autocmds — those live in spec config)
-- Based on LazyVim autocmds, using global autocmd() helper

-- Check if we need to reload the file when it changed
autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  callback = function()
    if vim.o.buftype ~= 'nofile' then
      vim.cmd('checktime')
    end
  end,
})

-- Highlight on yank
autocmd('TextYankPost', {
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Resize splits if window got resized
autocmd('VimResized', {
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd('tabdo wincmd =')
    vim.cmd('tabnext ' .. current_tab)
  end,
})

-- Close some filetypes with <q>
autocmd('FileType', {
  pattern = {
    'PlenaryTestPopup',
    'checkhealth',
    'dap-float',
    'dbout',
    'gitsigns-blame',
    'grug-far',
    'help',
    'lspinfo',
    'neotest-output',
    'neotest-output-panel',
    'neotest-summary',
    'notify',
    'qf',
    'spectre_panel',
    'startuptime',
    'tsplayground',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set('n', 'q', function()
        vim.cmd('close')
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = 'Quit buffer',
      })
    end)
  end,
})

-- Make man pages unlisted
autocmd('FileType', {
  pattern = { 'man' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- Wrap and spell in text filetypes
autocmd('FileType', {
  pattern = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for json files
autocmd('FileType', {
  pattern = { 'json', 'jsonc', 'json5' },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Git conflict markers highlight
do
  local utils = require('core.utils')
  utils.conflict_setup_hl()

  autocmd('ColorScheme', { callback = utils.conflict_setup_hl })
  autocmd({ 'BufReadPost', 'BufWritePost' }, {
    callback = function(event)
      utils.conflict_apply(event.buf)
    end,
  })
  autocmd('TextChanged', {
    callback = function(event)
      utils.conflict_apply_debounced(event.buf)
    end,
  })
end

-- Auto create dir when saving a file
autocmd('BufWritePre', {
  callback = function(event)
    if event.match:match('^%w%w+:[\\/][\\/]') then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- Large file detection — disable heavy features for performance
autocmd('BufReadPre', {
  callback = function(event)
    local size_limit = 1024 * 1024 * 1.5 -- 1.5 MB
    local ok, stat = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(event.buf))
    if not ok or not stat or stat.size <= size_limit then
      return
    end
    vim.b[event.buf].bigfile = true
    vim.opt_local.foldmethod = 'manual'
    vim.opt_local.spell = false
    vim.opt_local.swapfile = false
    vim.opt_local.undofile = false
    vim.schedule(function()
      vim.bo[event.buf].syntax = ''
      pcall(vim.treesitter.stop, event.buf)
    end)
  end,
})

-- Restore cursor to last known position
autocmd('BufReadPost', {
  callback = function(event)
    local exclude = { 'gitcommit', 'gitrebase', 'commit' }
    if vim.tbl_contains(exclude, vim.bo[event.buf].filetype) then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
