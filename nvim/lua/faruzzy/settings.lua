local g = vim.g
-- [[ Setting options ]]
-- See `:help vim.o`
local o = vim.opt

-- [[ Basic Keymaps ]]
-- Set <,> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
g.mapleader = ','
g.maplocalleader = ','

vim.api.nvim_set_option('clipboard', 'unnamed') -- Copies to the clipboard

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true
-- o.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Enable break indent
vim.o.breakindent = true

o.cmdheight = 2
-- o.noshowmode = true --TODO: nvim doesn't know about this, find alternative

-- Save undo history
vim.o.undofile = true

o.title = true
o.lazyredraw = true

o.lazyredraw = true
-- o.nowrap = true --TODO: nvim doesn't know about this, find alternative

o.linebreak = true
o.spelllang='en_us,fr'
o.display = 'lastline'

o.diffopt = 'filler'
-- o.shell = /bin/sh
o.timeoutlen = 1250

o.encoding = 'utf-8'
o.fileencodings = 'utf-8,cp932,euc-jp'
o.fileformats = 'unix,dos,mac'

-- should the following line be in?
-- o.autoindent = true 
o.smartindent = true
o.cindent = true

o.expandtab = true
-- o.shiftround = true
o.shiftwidth = 2
o.softtabstop = 2
o.tabstop = 2
o.list = true
o.backspace = 'indent,eol,start'

o.incsearch = true
-- Set highlight on search
o.hlsearch = true
o.ignorecase = true
o.smartcase = true
o.gdefault = true

vim.opt.backup = false
vim.opt.writebackup = false

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'
vim.opt.signcolumn = "yes"

o.matchtime = 2
o.splitright = true
o.splitbelow = true
o.binary = true

-- o.noeol = true --Todo: nvim doesn't know about this, find alternative
o.cursorline = true
-- o.nocursorcolumn = true --TODO: nvim doesn't know about this, find alternative
