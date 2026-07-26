local M = { gh('lewis6991/gitsigns.nvim') }

M.event = 'LazyFile'

M.init = function()
  Snacks.toggle({
    name = 'Git Signs',
    get = function()
      return require('gitsigns.config').config.signcolumn
    end,
    set = function(state)
      require('gitsigns').toggle_signs(state)
    end,
  }):map('<leader>uG')

  Snacks.toggle({
    name = 'Git Blame Line',
    get = function()
      return require('gitsigns.config').config.current_line_blame
    end,
    set = function(state)
      require('gitsigns').toggle_current_line_blame(state)
    end,
  }):map('<leader>uB')
end

---@module 'gitsigns'
---@type Gitsigns.Config
M.opts = {
  current_line_blame_opts = {
    delay = 300,
    virt_text = true,
    virt_text_pos = 'eol',
  },
  signs = {
    add = { text = '▎' },
    change = { text = '▎' },
    changedelete = { text = '▎' },
    delete = { text = '' },
    topdelete = { text = '' },
    untracked = { text = '▎' },
  },
  signs_staged = {
    add = { text = '▎' },
    change = { text = '▎' },
    changedelete = { text = '▎' },
    delete = { text = '' },
    topdelete = { text = '' },
  },
  on_attach = function(buffer)
    local gs = package.loaded.gitsigns

    local function kmap(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
    end

    -- stylua: ignore start
    kmap('n', ']h', function()
      if vim.wo.diff then vim.cmd.normal({ ']c', bang = true }) else gs.nav_hunk('next') end
    end, 'Next Hunk')
    kmap('n', '[h', function()
      if vim.wo.diff then vim.cmd.normal({ '[c', bang = true }) else gs.nav_hunk('prev') end
    end, 'Prev Hunk')
    kmap('n', ']H', function() gs.nav_hunk('last') end, 'Last Hunk')
    kmap('n', '[H', function() gs.nav_hunk('first') end, 'First Hunk')
    kmap({ 'n', 'x' }, '<leader>ghs', ':Gitsigns stage_hunk<CR>', 'Stage Hunk')
    kmap({ 'n', 'x' }, '<leader>ghr', ':Gitsigns reset_hunk<CR>', 'Reset Hunk')
    kmap('n', '<leader>ghS', gs.stage_buffer, 'Stage Buffer')
    kmap('n', '<leader>ghu', gs.undo_stage_hunk, 'Undo Stage Hunk')
    kmap('n', '<leader>ghR', gs.reset_buffer, 'Reset Buffer')
    kmap('n', '<leader>ghp', gs.preview_hunk_inline, 'Preview Hunk Inline')
    kmap('n', '<leader>ghb', function() gs.blame_line({ full = true }) end, 'Blame Line')
    kmap('n', '<leader>ghB', function() gs.blame() end, 'Blame Buffer')
    kmap('n', '<leader>ghd', gs.diffthis, 'Diff This')
    kmap('n', '<leader>ghD', function() gs.diffthis('~') end, 'Diff This ~')
    kmap({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'GitSigns Select Hunk')
    -- stylua: ignore end
  end,
}

return M
