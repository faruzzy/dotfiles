return {
  -- NOTE: First, some plugins that don't require any configuration
  'mattn/emmet-vim',
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
  'MaxMEllon/vim-jsx-pretty',
  'rcarriga/nvim-notify', -- Notifications library
  'tpope/vim-repeat', keys = { { '.', desc = 'REPEAT' } },
  'AndrewRadev/splitjoin.vim',
  'RRethy/vim-illuminate', -- automatically hightlight ohter uses of the word under the cursor
  {
    'Bekaboo/dropbar.nvim',
    -- optional, but required for fuzzy finder support
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim'
    }
  },
  {
    'nvim-pack/nvim-spectre',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = function ()
      vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', {
        desc = 'Toggle Spectre'
      })
      vim.keymap.set('n', '<leader>srw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
        desc = "Search and replace current word"
      })
      vim.keymap.set('v', '<leader>srw', '<cmd>lua require("spectre").open_visual()<CR>', {
        desc = "Search and replace current word"
      })
      vim.keymap.set('n', '<leader>sf', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
        desc = "Search on current file"
      })
    end
  },
}
