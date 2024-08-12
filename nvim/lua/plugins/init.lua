return {
  'mattn/emmet-vim',                                            -- provides support for expanding abbreviations similar to emmet
  'MaxMEllon/vim-jsx-pretty',                                   -- React syntax highlighting and indenting plugin for vim. Also supports the typescript tsx file.
  -- 'Issafalcon/lsp-overloads.nvim',
  'farmergreg/vim-lastplace',                                   -- Intelligently reopen files at your last edit position.
  'norcalli/nvim-colorizer.lua',                                -- A color highlighter for Neovim

  -- tmux integration
  'tmux-plugins/vim-tmux-focus-events',
  'christoomey/vim-tmux-navigator',
  'benmills/vimux',
  'wellle/tmux-complete.vim',                                   -- plugin for insert mode completion of words in adjacent tmux panes

  -- Git related plugins
  'tpope/vim-fugitive',                                         -- Git wrapper
  'tpope/vim-rhubarb',                                          -- Github extension for fugitive
  'junegunn/gv.vim',                                            -- A git commit browser
  'rhysd/git-messenger.vim', cmd = 'GitMessenger',              -- reveal the hidden message from Git under the cursor quickly in a popup window
  { "wintermute-cell/gitignore.nvim", dependencies = "nvim-telescope/telescope.nvim" },

  -- Misc
  'Pocco81/auto-save.nvim',                                     -- automatically save your changes so the world doesn't collapse
  'psliwka/vim-smoothie',                                       -- Smooth scrolling done right
  -- 'karb94/neoscroll.nvim',                                   -- look into this as a potential replacement for vim-smoothie
  'wsdjeg/vim-fetch',                                           -- Fetch that line and column, boy!
  'tpope/vim-sleuth',                                           -- Detect tabstop and shiftwidth automatically
  'rcarriga/nvim-notify',                                       -- Notifications library
  'tpope/vim-repeat', keys = { { '.', desc = 'REPEAT' } },
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
    end,
  },
}
