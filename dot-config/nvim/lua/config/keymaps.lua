-- Editor keymaps (no plugin keymaps — those live in spec keys/config)
-- Based on LazyVim keymaps, adapted for MiniPack

-- better up/down
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
map({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })
map({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map('n', '<C-h>', '<C-w>h', { desc = 'Go to Left Window', remap = true })
map('n', '<C-j>', '<C-w>j', { desc = 'Go to Lower Window', remap = true })
map('n', '<C-k>', '<C-w>k', { desc = 'Go to Upper Window', remap = true })
map('n', '<C-l>', '<C-w>l', { desc = 'Go to Right Window', remap = true })

-- Resize window using <ctrl> arrow keys
map('n', '<C-Up>', cmd('resize +2'), { desc = 'Increase Window Height' })
map('n', '<C-Down>', cmd('resize -2'), { desc = 'Decrease Window Height' })
map('n', '<C-Left>', cmd('vertical resize -2'), { desc = 'Decrease Window Width' })
map('n', '<C-Right>', cmd('vertical resize +2'), { desc = 'Increase Window Width' })

-- Move Lines
map('n', '<A-j>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move Down' })
map('n', '<A-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move Up' })
map('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move Down' })
map('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move Up' })
map('v', '<A-j>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = 'Move Down' })
map('v', '<A-k>', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = 'Move Up' })

-- Open with system app (override native desc)
map('n', 'gX', '<Cmd>call v:lua.vim.ui.open(expand("<cfile>"))<CR>', { desc = 'Open with System App' })

-- Buffers
map('n', '<S-h>', cmd('bprevious'), { desc = 'Prev Buffer' })
map('n', '<S-l>', cmd('bnext'), { desc = 'Next Buffer' })
map('n', '[b', cmd('bprevious'), { desc = 'Prev Buffer' })
map('n', ']b', cmd('bnext'), { desc = 'Next Buffer' })
map('n', '<leader>bb', cmd('e #'), { desc = 'Switch to Other Buffer' })
map('n', '<leader>`', cmd('e #'), { desc = 'Switch to Other Buffer' })
map('n', '<leader>bd', function() Snacks.bufdelete() end, { desc = 'Delete Buffer' })
map('n', '<leader>bo', function() Snacks.bufdelete.other() end, { desc = 'Delete Other Buffers' })
map('n', '<leader>bD', cmd('bd'), { desc = 'Delete Buffer and Window' })

-- Clear search and stop snippet on escape
map({ 'i', 'n', 's' }, '<esc>', function()
  vim.cmd('noh')
  return '<esc>'
end, { expr = true, desc = 'Escape and Clear hlsearch' })

-- Clear search, diff update and redraw
map('n', '<leader>ur', '<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>',
  { desc = 'Redraw / Clear hlsearch / Diff Update' })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next Search Result' })
map('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
map('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
map('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Prev Search Result' })
map('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })
map('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })

-- Add undo break-points
map('i', ',', ',<c-g>u', { desc = 'Undo Break-Point' })
map('i', '.', '.<c-g>u', { desc = 'Undo Break-Point' })
map('i', ';', ';<c-g>u', { desc = 'Undo Break-Point' })

-- Save file
map({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save File' })

-- Keywordprg
map('n', '<leader>K', cmd('norm! K'), { desc = 'Keywordprg' })

-- Better indenting
map('x', '<', '<gv', { desc = 'Dedent' })
map('x', '>', '>gv', { desc = 'Indent' })

-- Commenting
map('n', 'gco', 'o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add Comment Below' })
map('n', 'gcO', 'O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add Comment Above' })

-- New file
map('n', '<leader>fn', cmd('enew'), { desc = 'New File' })

-- Location list
map('n', '<leader>xl', function()
  local ok, err = pcall(function()
    if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
      vim.cmd.lclose()
    else
      vim.cmd.lopen()
    end
  end)
  if not ok and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = 'Location List' })

-- Quickfix list
map('n', '<leader>xq', function()
  local ok, err = pcall(function()
    if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
      vim.cmd.cclose()
    else
      vim.cmd.copen()
    end
  end)
  if not ok and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = 'Quickfix List' })

map('n', '[q', vim.cmd.cprev, { desc = 'Previous Quickfix' })
map('n', ']q', vim.cmd.cnext, { desc = 'Next Quickfix' })

-- Diagnostic
local diagnostic_goto = function(next, severity)
  return function()
    vim.diagnostic.jump({
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    })
  end
end

map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line Diagnostics' })
map('n', ']d', diagnostic_goto(true), { desc = 'Next Diagnostic' })
map('n', '[d', diagnostic_goto(false), { desc = 'Prev Diagnostic' })
map('n', ']e', diagnostic_goto(true, 'ERROR'), { desc = 'Next Error' })
map('n', '[e', diagnostic_goto(false, 'ERROR'), { desc = 'Prev Error' })
map('n', ']w', diagnostic_goto(true, 'WARN'), { desc = 'Next Warning' })
map('n', '[w', diagnostic_goto(false, 'WARN'), { desc = 'Prev Warning' })

-- Toggle options (via Snacks)
-- stylua: ignore start
Snacks.toggle.option('spell', { name = 'Spelling' }):map('<leader>us')
Snacks.toggle.option('wrap', { name = 'Wrap' }):map('<leader>uw')
Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map('<leader>uL')
Snacks.toggle.diagnostics():map('<leader>ud')
Snacks.toggle.line_number():map('<leader>ul')
Snacks.toggle.option('conceallevel',
  { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = 'Conceal Level' }):map('<leader>uc')
Snacks.toggle.option('showtabline', { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = 'Tabline' })
    :map('<leader>uA')
Snacks.toggle.treesitter():map('<leader>uT')
Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map('<leader>ub')
Snacks.toggle.dim():map('<leader>uD')
Snacks.toggle.animate():map('<leader>ua')
Snacks.toggle.indent():map('<leader>ug')
Snacks.toggle.scroll():map('<leader>uS')
Snacks.toggle.profiler():map('<leader>dpp')
Snacks.toggle.profiler_highlights():map('<leader>dph')
Snacks.toggle.zoom():map('<leader>wm'):map('<leader>uZ')
Snacks.toggle.zen():map('<leader>uz')

Snacks.toggle.new({
  name = 'Auto Format (Global)',
  get = function() return vim.g.autoformat ~= false end,
  set = function(state)
    vim.g.autoformat = state
    vim.b.autoformat = nil
  end,
}):map('<leader>uf')
Snacks.toggle.new({
  name = 'Auto Format (Buffer)',
  get = function()
    local buf = vim.b.autoformat
    if buf ~= nil then return buf end
    return vim.g.autoformat ~= false
  end,
  set = function(state) vim.b.autoformat = state end,
}):map('<leader>uF')
Snacks.toggle.inlay_hints():map('<leader>uh')
-- stylua: ignore end

-- Lazygit
if vim.fn.executable('lazygit') == 1 then
  map('n', '<leader>gg', function() Snacks.lazygit({ cwd = MiniPack.root_git() }) end, { desc = 'Lazygit (Root Dir)' })
  map('n', '<leader>gG', function() Snacks.lazygit() end, { desc = 'Lazygit (cwd)' })
end

-- Git
map('n', '<leader>gL', function() Snacks.picker.git_log() end, { desc = 'Git Log (cwd)' })
map('n', '<leader>gb', function() Snacks.picker.git_log_line() end, { desc = 'Git Blame Line' })
map('n', '<leader>gf', function() Snacks.picker.git_log_file() end, { desc = 'Git Current File History' })
map('n', '<leader>gl', function() Snacks.picker.git_log({ cwd = MiniPack.root_git() }) end, { desc = 'Git Log' })
map({ 'n', 'x' }, '<leader>gB', function() Snacks.gitbrowse() end, { desc = 'Git Browse (open)' })
map({ 'n', 'x' }, '<leader>gY', function()
  Snacks.gitbrowse({ open = function(url) vim.fn.setreg('+', url) end, notify = false })
end, { desc = 'Git Browse (copy)' })

-- Quit
map('n', '<leader>qq', cmd('qa'), { desc = 'Quit All' })

-- Highlights under cursor
map('n', '<leader>ui', vim.show_pos, { desc = 'Inspect Pos' })
map('n', '<leader>uI', function()
  vim.treesitter.inspect_tree()
  vim.api.nvim_input('I')
end, { desc = 'Inspect Tree' })

-- Floating terminal
map('n', '<leader>fT', function() Snacks.terminal() end, { desc = 'Terminal (cwd)' })
map('n', '<leader>ft', function() Snacks.terminal(nil, { cwd = MiniPack.root() }) end, { desc = 'Terminal (Root Dir)' })
map({ 'n', 't' }, '<c-/>', function() Snacks.terminal.focus(nil, { cwd = MiniPack.root() }) end,
  { desc = 'Terminal (Root Dir)' })
map({ 'n', 't' }, '<c-_>', function() Snacks.terminal.focus(nil, { cwd = MiniPack.root() }) end,
  { desc = 'which_key_ignore' })

-- Windows
map('n', '<leader>ww', '<C-W>p', { desc = 'Other Window', remap = true })
map('n', '<leader>-', '<C-W>s', { desc = 'Split Window Below', remap = true })
map('n', '<leader>|', '<C-W>v', { desc = 'Split Window Right', remap = true })
map('n', '<leader>wd', '<C-W>c', { desc = 'Delete Window', remap = true })

-- Tabs
map('n', '<leader><tab>l', cmd('tablast'), { desc = 'Last Tab' })
map('n', '<leader><tab>o', cmd('tabonly'), { desc = 'Close Other Tabs' })
map('n', '<leader><tab>f', cmd('tabfirst'), { desc = 'First Tab' })
map('n', '<leader><tab><tab>', cmd('tabnew'), { desc = 'New Tab' })
map('n', '<leader><tab>]', cmd('tabnext'), { desc = 'Next Tab' })
map('n', '<leader><tab>d', cmd('tabclose'), { desc = 'Close Tab' })
map('n', '<leader><tab>[', cmd('tabprevious'), { desc = 'Previous Tab' })

-- MiniPack
map('n', '<leader>Mo', cmd('MiniPack open'), { desc = 'Open' })
map('n', '<leader>Mu', cmd('MiniPack update'), { desc = 'Update' })
map('n', '<leader>Mc', cmd('MiniPack check'), { desc = 'Check Updates' })
map('n', '<leader>Mx', cmd('MiniPack clean'), { desc = 'Clean' })
map('n', '<leader>Mh', cmd('MiniPack health'), { desc = 'Health' })
map('n', '<leader>Mr', cmd('MiniPack reload'), { desc = 'Reload' })
map('n', '<leader>Mt', cmd('MiniPack test'), { desc = 'Tests' })
