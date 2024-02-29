return {
  -- NOTE: First, some plugins that don't require any configuration
  'mattn/emmet-vim',
  'MaxMEllon/vim-jsx-pretty',
  -- 'Issafalcon/lsp-overloads.nvim',
  'farmergreg/vim-lastplace',                                   -- Intelligently reopen files at your last edit position.
  'norcalli/nvim-colorizer.lua',

  -- tmux integration
  'tmux-plugins/vim-tmux-focus-events',
  'christoomey/vim-tmux-navigator',
  'benmills/vimux',
  'wellle/tmux-complete.vim',

  -- Git related plugins
  'tpope/vim-fugitive',                                         -- Git wrapper
  'tpope/vim-rhubarb',                                          -- Github extension for fugitive
  'junegunn/gv.vim',                                            -- A git commit browser
  'rhysd/git-messenger.vim', cmd = 'GitMessenger',

  -- Misc
  'Pocco81/auto-save.nvim',                                     -- automatically save your changes so the world doesn't collapse
  'psliwka/vim-smoothie',                                       -- Smooth scrolling done right
  -- 'karb94/neoscroll.nvim',                                   -- look into this as a potential replacement for vim-smoothie
  'wsdjeg/vim-fetch',                                           -- Fetch that line and column, boy!
  'tpope/vim-sleuth',                                           -- Detect tabstop and shiftwidth automatically
  'rcarriga/nvim-notify',                                       -- Notifications library
  'tpope/vim-repeat', keys = { { '.', desc = 'REPEAT' } },
  'AndrewRadev/splitjoin.vim',
  'RRethy/vim-illuminate',                                      -- automatically hightlight ohter uses of the word under the cursor
  'moll/vim-bbye',                                              -- allows you to delete buffers without closing your windows or messing up your layout
  { 'gbprod/stay-in-place.nvim', opts = {} },                   -- prevent the cursor from moving when using shift and filter actions
  { 'ellisonleao/glow.nvim', config = true, cmd = 'Glow' },     -- preview markdown code directly in your neovim terminal
  { 'folke/trouble.nvim', config = true, cmd = 'Trouble' },     -- pretty list for showing diagnostics, quickfix to help solve the trouble
    "toppair/peek.nvim",
    event = { "VeryLazy" },
    build = "deno task --quiet build:fast",
    config = function()
        require("peek").setup()
        -- refer to `configuration to change defaults`
        vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
        vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
  },
  {
    'glacambre/firenvim',

    -- Lazy load firenvim
    -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
    lazy = not vim.g.started_by_firenvim,
    build = function()
      vim.fn["firenvim#install"](0)
    end
  },
  { "folke/trouble.nvim", config = true, cmd = 'Trouble' }      -- pretty list for showing diagnostics, quickfix to help solve the trouble
}
