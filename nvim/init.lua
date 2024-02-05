--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]
require('faruzzy.settings')

-- Set comma ',' as the leader key
-- See `:help mapleader`
-- NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {
  change_detection = { notify = false },
  checker = { enabled = true, notify = false },
})

--[[ require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration
  'mattn/emmet-vim',
  'windwp/nvim-ts-autotag', -- Use treesitter to autoclose and autorename html tags
  'Issafalcon/lsp-overloads.nvim',
  'farmergreg/vim-lastplace', -- Intelligently reopen files at your last edit position.
  'norcalli/nvim-colorizer.lua',

  -- tmux integration
  'tmux-plugins/vim-tmux-focus-events',
  'christoomey/vim-tmux-navigator',
  'benmills/vimux',
  'wellle/tmux-complete.vim',

  -- Git related plugins
  'tpope/vim-fugitive', -- Git wrapper
  'tpope/vim-rhubarb', -- Github extension for fugitive
  'junegunn/gv.vim', -- A git commit browser
  'rhysd/git-messenger.vim', cmd = 'GitMessenger',

  -- Misc
  'Pocco81/auto-save.nvim', -- automatically save your changes so the world doesn't collapse
  'psliwka/vim-smoothie', -- Smooth scrolling done right
  -- 'karb94/neoscroll.nvim', -- look into this as a potential replacement for vim-smoothie
  'wsdjeg/vim-fetch', -- Fetch that line and column, boy!
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  'mbbill/undotree',
  'MaxMEllon/vim-jsx-pretty',
  'rcarriga/nvim-notify', -- Notifications library
  'tpope/vim-repeat', keys = { { '.', desc = 'REPEAT' } },
  'AndrewRadev/splitjoin.vim',
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  {
    'nvim-neo-tree/neo-tree.nvim',
    cmd = 'Neotree',
    branch = 'v2.x',
    keys = {
      { '<C-c>', '<cmd>Neotree toggle<cr>', desc = 'Neotree' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('neo-tree').setup({
        close_if_last_window = true,
        filesystem = {
          follow_current_file = true,
          hijack_netrw_behavior = 'open_current',
        }
      })
    end
  },

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter *.*',
    config = autoPairs_config
    -- config = function() require('nvim-autopairs').setup {} end
  },

  -- Easy motion like plugin that allows you to jump anywhere in a document
  {
    'phaazon/hop.nvim',
    branch = 'v2', -- optional but strongly recommended
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
    end
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})
]]

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

vim.o.hlsearch = false        -- Set highlight on search

vim.wo.number = true          -- Display the real number
vim.wo.relativenumber = true  -- Make line numbers relative by default

vim.wo.cursorline = true      -- hightlight current line

vim.o.mouse = 'a'             -- Enable mouse mode

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- set vim diff options
vim.o.diffopt = 'internal,filler,closeoff,vertical'
vim.o.splitright = true
vim.o.splitbelow = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Spaces and Tabs
vim.o.expandtab = true        -- on pressing tab, insert 2 spaces
vim.o.shiftround = true
vim.o.shiftwidth = 2          -- when indenting '>', use 2 spaces width
vim.o.softtabstop = 2
vim.o.tabstop = 2             -- show eisting tab with 2 spaces width
vim.o.list = true
vim.opt.backspace = { 'indent', 'eol', 'start' }        -- make backspace work properly

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Quickly save the current buffer or all buffers
vim.keymap.set('n', '<leader>w', '<CMD>update<CR>')
vim.keymap.set('n', '<leader>W', '<CMD>wall<CR>')

vim.keymap.set('n', '<leader>x', ':x<CR>')
vim.keymap.set('n', '<leader>X', ':wqa!<CR>')

-- GV
vim.keymap.set('n', '<leader>gv', ':GV<cr>')
vim.keymap.set('n', '<leader>Gv', ':GV!<cr>')

-- turn off higlighting until the next search
vim.keymap.set('n', '<leader>n', ':noh<cr>')

if vim.lsp.inlay_hint then
  vim.keymap.set(
  'n',
  '<leader>uh',
  function () vim.lsp.inlay_hint.enable(0, nil) end,
    { desc = 'Toggle Inlay Hints' }
  )
end

-- fugitive
vim.keymap.set('n', '<leader>ga', ':Git add %:p<cr><cr>')
vim.keymap.set('n', '<leader>gm', ':Gmove<cr>')
vim.keymap.set('n', '<leader>gy', ':Gremove<cr>')
vim.keymap.set('n', '<leader>gl', ':Git pull<cr>')
vim.keymap.set('n', '<leader>gc', ':Git commit<cr>')
vim.keymap.set('n', '<leader>gd', ':Gvdiffsplit<cr>')
vim.keymap.set('n', '<leader>gs', ':Git<cr>', { noremap = true })
vim.keymap.set('n', '<leader>gg', ':Gmerge<cr>')
vim.keymap.set('n', '<leader>pp', ':Git push origin master<cr>')

-- Undotree
vim.keymap.set('n', '<leader>ut', vim.cmd.UndotreeToggle)

-- This command prompts you to type one key, and will hint that key in the buffer.
vim.keymap.set('n', '<leader>,', ':HopChar1<cr>')

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
--[[ local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end ]]

-- vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
--[[ vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end
vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<C-p>', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<C-g>', '<cmd>Telescope resume<CR>') ]]

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
