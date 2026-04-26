-- Editor options (vim.opt)
local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Indentation
opt.breakindent = true
opt.breakindentopt = 'list:-1'
opt.expandtab = true
opt.shiftround = true
opt.shiftwidth = 2
opt.smartindent = true
opt.tabstop = 2

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = 'nosplit'

-- Display
opt.colorcolumn = '120'
opt.conceallevel = 2
opt.cursorline = true
opt.cursorlineopt = 'screenline,number'
opt.endofline = true
opt.fixendofline = true
opt.linebreak = true
opt.listchars = { extends = '…', nbsp = '␣', precedes = '…', tab = '> ', trail = '·' }
opt.mousescroll = 'ver:25,hor:6'
opt.ruler = false
opt.scrolloff = 4
opt.sidescrolloff = 8
opt.showmode = false
opt.signcolumn = 'yes:2'
opt.statuscolumn = [[%!v:lua.MiniPack.statuscolumn()]]
opt.termguicolors = true
opt.wrap = false

-- Splits
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = 'screen'

-- Completion
opt.completeopt = 'menu,menuone,noselect,fuzzy'
opt.pumblend = vim.g.winblend
opt.pumborder = vim.g.border
opt.pumheight = 10
opt.pummaxwidth = 100

-- Folds (nvim-ufo manages providers)
opt.foldenable = true
opt.foldcolumn = '1'
opt.foldlevel = 99
opt.foldlevelstart = 100
opt.foldnestmax = 10
opt.foldtext = ''
opt.fillchars = { diff = '╱', eob = ' ', fold = ' ', foldclose = '>', foldopen = 'v', foldsep = ' ' }

-- Files
opt.autoread = true
opt.autowrite = true
opt.confirm = true
opt.shada = "'100,<50,s10,:1000,/100,@100,h"
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200

-- Clipboard
opt.clipboard = vim.env.SSH_CONNECTION and '' or 'unnamedplus'

-- Window
opt.winblend = vim.g.winblend
opt.winborder = vim.g.border
opt.winminwidth = 5

-- Misc
opt.formatexpr = 'v:lua.MiniPack.formatexpr()'
opt.formatoptions = 'jcroqlnt'
opt.grepformat = '%f:%l:%c:%m'
opt.grepprg = 'rg --vimgrep'
opt.jumpoptions = 'view'
opt.laststatus = 3
opt.list = true
opt.mouse = 'a'
opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' }
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.smoothscroll = true
opt.spelllang = { 'en', 'pt_br' }
opt.timeoutlen = vim.g.vscode and 1000 or 300
opt.virtualedit = 'block'
opt.wildmode = 'longest:full,full'
