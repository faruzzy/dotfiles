return {
  -- NOTE: First, some plugins that don't require any configuration
  'mattn/emmet-vim',
  'MaxMEllon/vim-jsx-pretty',
  -- 'Issafalcon/lsp-overloads.nvim',
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
  'rcarriga/nvim-notify', -- Notifications library
  'tpope/vim-repeat', keys = { { '.', desc = 'REPEAT' } },
  'AndrewRadev/splitjoin.vim',
  'RRethy/vim-illuminate', -- automatically hightlight ohter uses of the word under the cursor
}
