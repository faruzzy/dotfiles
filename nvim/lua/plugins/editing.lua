return {
  {
    'farmergreg/vim-lastplace',
    event = 'BufReadPost',
    desc = 'Intelligently reopen files at last edit position',
  },

  { 'lewis6991/spaceless.nvim', event = 'BufReadPost' },

  {
    'okuuva/auto-save.nvim',
    version = '*',
    event = { 'InsertEnter', 'BufReadPost', 'BufNewFile' },
    cmd = 'ASToggle',
    opts = {
      trigger_events = {
        immediate_save = { 'FocusLost', 'BufLeave' },
        defer_save = { 'InsertLeave', 'TextChanged' },
        cancel_deferred_save = { 'InsertEnter' },
      },
      condition = function(buf)
        if not vim.api.nvim_buf_is_valid(buf) then
          return false
        end
        if vim.bo[buf].buftype ~= '' then
          return false
        end
        if vim.api.nvim_buf_get_name(buf) == '' then
          return false
        end
        local excluded = {
          'oil',
          'harpoon',
          'alpha',
          'dashboard',
          'fugitive',
          'typescriptreact',
          'javascriptreact',
        }
        return not vim.tbl_contains(excluded, vim.bo[buf].filetype)
      end,
      write_all_buffers = false,
      debounce_delay = 500,
    },
    desc = 'Auto-save on focus loss (disabled for tsx/jsx)',
  },

  {
    'andythigpen/nvim-coverage',
    version = '*',
    config = function()
      require('coverage').setup({
        auto_reload = true,
        commands = {
          jest = {
            coverage_file = './coverage/lcov.info',
          },
        },
      })
    end,
  },

  {
    'wesQ3/vim-windowswap',
    keys = {
      { '<Leader>ww', '<cmd>WindowSwap<cr>', desc = 'Window: Swap' },
    },
    desc = 'Swap windows without layout disruption',
  },

  {
    'wellle/visual-split.vim',
    keys = {
      { '<C-w>gr', mode = 'x', desc = 'Split: Visual selection right' },
      { '<C-w>gb', mode = 'x', desc = 'Split: Visual selection below' },
      { '<C-w>gR', mode = 'x', desc = 'Split: Visual selection above' },
      { '<C-w>gL', mode = 'x', desc = 'Split: Visual selection left' },
    },
    desc = 'Control splits with visual selections',
  },

  {
    'wsdjeg/vim-fetch',
    desc = 'Handle file:line:col syntax',
  },

  {
    'tpope/vim-sleuth',
    event = 'BufReadPost',
    desc = 'Automatic indentation detection',
  },

  {
    'tpope/vim-repeat',
    keys = { { '.', desc = 'Repeat last command' } },
    desc = 'Enhanced repeat functionality',
  },

  {
    'inkarkat/vim-visualrepeat',
    dependencies = { 'tpope/vim-repeat' },
    keys = { { '.', mode = 'x', desc = 'Repeat in visual mode' } },
    desc = 'Visual mode repeat support',
  },

  {
    'tpope/vim-rsi',
    event = { 'InsertEnter', 'CmdlineEnter' },
    desc = 'Readline keybindings in insert/command mode',
  },

  {
    'AndrewRadev/splitjoin.vim',
    keys = {
      { 'gS', desc = 'Split: Single to multi-line' },
      { 'gJ', desc = 'Join: Multi to single-line' },
    },
    desc = 'Toggle between single/multi-line statements',
  },

  {
    'jordwalke/VimSplitBalancer',
    event = 'WinNew',
    desc = 'Distribute space among vertical splits',
  },

  {
    'moll/vim-bbye',
    lazy = false,
    keys = {
      { '<Leader>bd', '<cmd>Bdelete<cr>', desc = 'Delete buffer (preserve layout)' },
      { '<Leader>bD', '<cmd>Bdelete!<cr>', desc = 'Delete buffer (force)' },
    },
    desc = 'Delete buffers without closing windows',
  },

  {
    'gbprod/stay-in-place.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {},
    desc = 'Prevent cursor movement during shift/filter actions',
  },

  { 'svban/YankAssassin.vim', event = 'VeryLazy', desc = 'After yank leave cursor in its place' },

  {
    'andymass/vim-matchup',
    event = 'BufReadPost',
    init = function() vim.g.matchup_delim_nomids = 1 end,
    config = function()
      require('match-up').setup({
        delim = {
          nomids = 1,
        },
        matchparen = {
          offscreen = { method = 'popup' },
        },
        treesitter = {
          enabled = true,
        },
      })
    end,
    desc = 'Extended % matching for HTML/JSX/TSX tags and language constructs',
  },

  {
    'hrsh7th/nvim-pasta',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      vim.keymap.set({ 'n', 'x' }, 'p', require('pasta.mapping').p, { desc = 'Paste with context' })
      vim.keymap.set({ 'n', 'x' }, 'P', require('pasta.mapping').P, { desc = 'Paste before with context' })
    end,
    desc = 'Context-aware pasting with indentation',
  },
}
