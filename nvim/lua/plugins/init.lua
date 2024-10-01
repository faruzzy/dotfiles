-- stylua: ignore

return {
  'mattn/emmet-vim',                                            -- Provides support for expanding abbreviations similar to emmet
  'MaxMEllon/vim-jsx-pretty',                                   -- React syntax highlighting and indenting plugin for vim.
  -- 'Issafalcon/lsp-overloads.nvim',
  'farmergreg/vim-lastplace',                                   -- Intelligently reopen files at your last edit position.
  'norcalli/nvim-colorizer.lua',                                -- A color highlighter for Neovim

  -- tmux integration
  'tmux-plugins/vim-tmux-focus-events',
  'christoomey/vim-tmux-navigator',
  {
    'benmills/vimux',
    keys = {
      { '<Leader>vr', '<cmd>VimuxPromptCommand<cr>', desc = 'Vimux Prompt Command' },
      { '<Leader>vl', '<cmd>VimuxRunLastCommand<cr>', desc = 'Vimux Run Last Command' },
      { '<Leader>vi', '<cmd>VimuxInterruptRunner<cr>', desc = 'Vimux Interrupt Runner' },
      { '<Leader>vc', '<cmd>VimuxCloseRunner<cr>', desc = 'Vimux Close Runner' },
      { '<Leader>vz', '<cmd>VimuxZoomRunner<cr>', desc = 'Vimux Zoom Runner' },
      { '<Leader>vt', '<cmd>VimuxTogglePane<cr>', desc = 'Vimux Toggle Pane' },
    }
  },
  'wellle/tmux-complete.vim',                                   -- plugin for insert mode completion of words in adjacent tmux panes

  -- Git related plugins
  {
    'tpope/vim-fugitive',                                       -- Git wrapper
    keys = {
      { '<Leader>ga', '<cmd>Git add %:p<cr><cr>', desc = 'Git Add' },
      { '<Leader>gp', '<cmd>Git pull<cr>', desc = 'Git Pull' },
      { '<Leader>pp', '<cmd>Git push origin master<cr>', desc = 'Git Push Master' },
      { '<Leader>gs', '<cmd>Git<cr>', desc = 'Git Status' },
      { 'g<cr>', '<cmd>Git<cr>', desc = 'Git Status' }, -- find this shorter
      { '<Leader>gc', '<cmd>Git commit<cr>', desc = 'Git Commit' },
      { '<Leader>gd', '<cmd>Gvdiffsplit<cr>', desc = 'Git Diff' },
    },
    dependencies = { 'tpope/vim-rhubarb' }                      -- Github extension for fugitive
  },
  'junegunn/gv.vim',                                            -- A git commit browser TODO: fix GV not working
  'rhysd/git-messenger.vim', cmd = 'GitMessenger',              -- reveal the hidden message from Git under the cursor quickly in a popup window
  {
    "wintermute-cell/gitignore.nvim",                           -- plugin for generating .gitignore files in seconds, by allowing you to select from a huge number of different technologies
    dependencies = "nvim-telescope/telescope.nvim",
  },

  -- Language specifics
  'pantharshit00/vim-prisma',                                   -- Provides file detection and syntax highlighting suppor for Prisma files
  'jparise/vim-graphql',                                        -- Provides fie detection, syntax highlighting and indentation.
  'udalov/javap-vim',                                           -- Allows you to read the decompiled bytecode of a JVM class file
  'MeanderingProgrammer/render-markdown.nvim',                  -- Improves viewing Markdown files in Neovim

  'wesQ3/vim-windowswap',                                       -- Swap windows without ruining your layout
  'wellle/visual-split.vim',

  -- Misc
  'Pocco81/auto-save.nvim',                                     -- automatically save your changes so the world doesn't collapse
  'psliwka/vim-smoothie',                                       -- Smooth scrolling done right
  -- 'karb94/neoscroll.nvim',                                   -- look into this as a potential replacement for vim-smoothie
  'wsdjeg/vim-fetch',                                           -- Fetch that line and column, boy!
  'tpope/vim-sleuth',                                           -- Detect tabstop and shiftwidth automatically
  'rcarriga/nvim-notify',                                       -- Notifications library
  'tpope/vim-repeat', keys = { { '.', desc = 'REPEAT' } },      -- Allows you to use the repeat the last native command `.` more than once
  { 'tpope/vim-rsi', event = { 'InsertEnter *', 'CmdlineEnter' } }, -- Extend Readline keybindings to neovim TODO: Replace with linty-org/readline.nvim
  'AndrewRadev/splitjoin.vim',                                  -- Makes switching between a single-line statement and a multi-line one easy
  'RRethy/vim-illuminate',                                      -- automatically highlight other uses of the word under the cursor
  'jordwalke/VimSplitBalancer',                                 -- Distributes available space among vertical splits
  'moll/vim-bbye',                                              -- allows you to delete buffers without closing your windows or messing up your layout
  { 'gbprod/stay-in-place.nvim', opts = {} },                   -- prevent the cursor from moving when using shift and filter actions
  { 'ellisonleao/glow.nvim', config = true, cmd = 'Glow' },     -- preview markdown code directly in your neovim terminal
  { 'folke/trouble.nvim', config = true, cmd = 'Trouble' },     -- pretty list for showing diagnostics, quickfix to help solve the trouble
  {
    'fei6409/log-highlight.nvim',                               -- Neovim plugin that brings syntax highlighting to generic log files
    config = function()
      require('log-highlight').setup {}
    end
  },
  {                                                             -- Pasting with indentation adjusted to destination context
    'hrsh7th/nvim-pasta',
    config = function ()
      vim.keymap.set({ 'n', 'x' }, 'p', require('pasta.mapping').p)
      vim.keymap.set({ 'n', 'x' }, 'P', require('pasta.mapping').P)
    end
  }
}
