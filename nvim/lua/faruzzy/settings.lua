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
-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

vim.wo.number = true          -- Display the real number on the current line
vim.wo.relativenumber = true  -- Display the relative number for everything else
vim.o.cursorline = true

vim.o.mouse = 'a'             -- Enable mouse mode

vim.o.termguicolors = true

-- Enable break indent
vim.o.breakindent = true

o.cmdheight = 2
-- o.noshowmode = true --TODO: nvim doesn't know about this, find alternative

-- Save undo history
vim.o.undofile = true

o.title = true

-- o.lazyredraw = true
-- o.nowrap = true --TODO: nvim doesn't know about this, find alternative

o.linebreak = true
o.spelllang='en_us,fr'
o.display = 'lastline'

-- set vim diff options
vim.o.diffopt = 'internal,filler,closeoff,vertical'
vim.o.splitright = true
vim.o.splitbelow = true

-- o.shell = /bin/sh

o.encoding = 'utf-8'
o.fileencodings = 'utf-8,cp932,euc-jp'
o.fileformats = 'unix,dos,mac'

-- should the following line be in?
-- o.autoindent = true 
o.smartindent = true
-- o.cindent = true

-- Spaces and Tabs
o.expandtab = true
o.shiftround = true
o.shiftwidth = 2
o.softtabstop = 2
o.tabstop = 2
o.list = true
vim.opt.backspace = { 'indent', 'eol', 'start' }        -- make backspace work properly

o.incsearch = true
-- Set highlight on search
o.hlsearch = true
-- Case-insensitive searching UNLESS \C or capital in search
o.ignorecase = true
o.smartcase = true

o.gdefault = true

o.backup = false
o.writebackup = false
o.swapfile = false

vim.o.completeopt = 'menuone,noselect'  -- Set completeopt to have a better completion experience

vim.o.updatetime = 250 -- Decrease update time
vim.o.timeoutlen = 1250

vim.wo.signcolumn = 'yes' -- Keep signcolumn on by default
o.signcolumn = "yes"

o.matchtime = 2
-- o.splitkeep = 'screen'

-- o.noeol = true --Todo: nvim doesn't know about this, find alternative
-- o.nocursorcolumn = true --TODO: nvim doesn't know about this, find alternative
