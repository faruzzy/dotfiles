local g = vim.g
local o = vim.opt

g.mapleader = ','
g.maplocalleader = ','

vim.g.have_nerd_font = true

vim.api.nvim_set_option_value('clipboard', 'unnamed', {}) -- Copies to the clipboard
vim.o.clipboard = 'unnamedplus'

vim.wo.number = true          -- Display the real number on the current line
vim.wo.relativenumber = true  -- Display the relative number for everything else
vim.o.cursorline = true
vim.o.scrolloff = 5           -- Determines the number of context lines you would like to see above and below the cursor

vim.o.mouse = 'a'             -- Enable mouse mode

vim.o.termguicolors = true

vim.o.linebreak = true
vim.o.breakindent = true

o.cmdheight = 2

-- Save undo history
vim.o.undofile = true

o.title = true

o.spelllang='en_us,fr'
o.display = 'lastline'

-- set vim diff options
vim.o.diffopt = 'internal,filler,closeoff,vertical'
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.splitkeep = 'screen'

-- Spaces and Tabs
o.expandtab = true
o.shiftwidth = 2
o.softtabstop = 2
o.tabstop = 2
o.list = true
vim.opt.backspace = { 'indent', 'eol', 'start' }        -- make backspace work properly

o.incsearch = true
o.hlsearch = true   -- Set highlight on search
o.ignorecase = true -- Case-insensitive searching UNLESS \C or capital in search
o.smartcase = true

o.gdefault = true

o.backup = false
o.writebackup = false
o.swapfile = false

vim.o.completeopt = 'menuone,noselect'  -- Set completeopt to have a better completion experience

vim.o.updatetime = 250 -- Decrease update time
vim.o.timeoutlen = 250 -- Displays which-key popup sooner

vim.wo.signcolumn = 'yes' -- Keep signcolumn on by default
o.signcolumn = "yes"

o.matchtime = 2
vim.o.matchpairs = vim.o.matchpairs .. ',<:>'
