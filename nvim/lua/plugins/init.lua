-- stylua: ignore

return {
  -- === WEB DEVELOPMENT ===
  {
    'mattn/emmet-vim',
    event = { 'BufRead *.html', 'BufRead *.css', 'BufRead *.js', 'BufRead *.jsx', 'BufRead *.ts', 'BufRead *.tsx', 'BufRead *.vue', 'BufRead *.svelte' },
    desc = 'Emmet abbreviation expansion for web development'
  },

  {
    'MaxMEllon/vim-jsx-pretty',
    ft = { 'javascript', 'typescript', 'jsx', 'tsx' },
    desc = 'React syntax highlighting and indenting'
  },

  -- === NAVIGATION & EDITING ===
  {
    'farmergreg/vim-lastplace',
    event = 'BufReadPost',
    desc = 'Intelligently reopen files at last edit position'
  },

  {
    'norcalli/nvim-colorizer.lua',
    event = 'BufReadPost',
    desc = 'Color highlighter for CSS/hex colors'
  },

  {
    "andythigpen/nvim-coverage",
    version = "*",
    config = function()
      require("coverage").setup({
        auto_reload = true,
        commands = {
          jest = {
            coverage_file = "./coverage/lcov.info"
          }
        }
      })
    end,
  },

  -- === TMUX INTEGRATION ===
  {
    'christoomey/vim-tmux-navigator',
    keys = {
      { '<C-h>', '<cmd>TmuxNavigateLeft<cr>',  desc = 'Navigate Left' },
      { '<C-j>', '<cmd>TmuxNavigateDown<cr>',  desc = 'Navigate Down' },
      { '<C-k>', '<cmd>TmuxNavigateUp<cr>',    desc = 'Navigate Up' },
      { '<C-l>', '<cmd>TmuxNavigateRight<cr>', desc = 'Navigate Right' },
    },
    desc = 'Seamless vim/tmux navigation'
  },

  {
    'benmills/vimux',
    keys = {
      { '<Leader>vr', '<cmd>VimuxPromptCommand<cr>',   desc = 'Vimux: Prompt Command' },
      { '<Leader>vl', '<cmd>VimuxRunLastCommand<cr>',  desc = 'Vimux: Run Last Command' },
      { '<Leader>vi', '<cmd>VimuxInterruptRunner<cr>', desc = 'Vimux: Interrupt Runner' },
      { '<Leader>vc', '<cmd>VimuxCloseRunner<cr>',     desc = 'Vimux: Close Runner' },
      { '<Leader>vz', '<cmd>VimuxZoomRunner<cr>',      desc = 'Vimux: Zoom Runner' },
      { '<Leader>vt', '<cmd>VimuxTogglePane<cr>',      desc = 'Vimux: Toggle Pane' },
    },
    desc = 'Tmux integration for running commands'
  },

  {
    'wellle/tmux-complete.vim',
    event = 'InsertEnter',
    desc = 'Insert mode completion from tmux panes'
  },

  -- === GIT INTEGRATION ===
  {
    'tpope/vim-fugitive',
    dependencies = { 'tpope/vim-rhubarb' },
    cmd = { 'Git', 'Gstatus', 'Gblame', 'Glog', 'Gcommit' },
    keys = {
      { '<Leader>ga', '<cmd>execute "silent !git add " . shellescape(expand("%:p"))<CR>', desc = 'Git: Add current file' },
      { '<Leader>gp', '<cmd>Git pull<cr>',                                                desc = 'Git: Pull' },
      { '<Leader>gP', '<cmd>Git push<cr>',                                                desc = 'Git: Push' },
      { 'g<cr>',      '<cmd>Git<cr>',                                                     desc = 'Git: Status' },
      { '<Leader>gc', '<cmd>Git commit<cr>',                                              desc = 'Git: Commit' },
      { '<Leader>gd', '<cmd>Gvdiffsplit!<cr>',                                            desc = 'Git: Diff split' },
      { '<Leader>gr', '<cmd>Gdiffsplit! HEAD~1<cr>',                                      desc = 'Git: Reversed diff of most recent commit' },
      { '<Leader>gb', '<cmd>Git blame<cr>',                                               desc = 'Git: Blame' },
      { '<Leader>gl', '<cmd>Git log --oneline<cr>',                                       desc = 'Git: Log' },
    },
    desc = 'Git wrapper with comprehensive commands'
  },

  {
    'junegunn/gv.vim',
    dependencies = { 'tpope/vim-fugitive' },
    keys = {
      { '<Leader>gv', '<cmd>GV<cr>',  desc = 'Git: Commit browser' },
      { '<Leader>gV', '<cmd>GV!<cr>', desc = 'Git: Commit browser (current file)' },
    },
    desc = 'Git commit browser'
  },

  {
    'rhysd/git-messenger.vim',
    cmd = 'GitMessenger',
    keys = {
      { '<Leader>gm', '<cmd>GitMessenger<cr>', desc = 'Git: Show commit message' },
    },
    desc = 'Show git commit message in popup'
  },

  {
    'wintermute-cell/gitignore.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    cmd = 'Gitignore',
    keys = {
      { '<Leader>gi', '<cmd>Gitignore<cr>', desc = 'Generate .gitignore' },
    },
    desc = 'Generate .gitignore files'
  },

  -- === LANGUAGE SPECIFIC ===
  {
    'Sebastian-Nielsen/better-type-hover',
    ft = { 'typescript', 'typescriptreact' },
    config = function()
      require('better-type-hover').setup({
        openTypeDocKeymap = 'K',
      })
    end,
    desc = 'Improved TypeScript hover documentation'
  },
  ---@type LazySpec
  {
    'dmmulroy/tsc.nvim',
    cmd = 'TSC',
    ---@module 'tsc'
    ---@type Opts
    opts = {
      pretty_errors = false,
    },
  },

  {
    'pantharshit00/vim-prisma',
    ft = 'prisma',
    desc = 'Prisma file detection and syntax highlighting'
  },

  {
    'jparise/vim-graphql',
    ft = { 'graphql', 'javascript', 'typescript' },
    desc = 'GraphQL syntax highlighting and indentation'
  },

  {
    'udalov/javap-vim',
    ft = 'java',
    cmd = 'Javap',
    desc = 'Java bytecode decompiler'
  },

  -- === PRODUCTIVITY & UTILITIES ===
  {
    'Pocco81/auto-save.nvim',
    event = { 'InsertLeave', 'TextChanged' },
    config = function()
      require('auto-save').setup({
        enabled = true,
        execution_message = {
          message = function()
            return ('AutoSave: saved at ' .. vim.fn.strftime('%H:%M:%S'))
          end,
          dim = 0.18,
          cleaning_interval = 1250,
        },
        trigger_events = { 'InsertLeave', 'TextChanged' },
        condition = function(buf)
          -- Don't auto-save for certain filetypes
          local excluded_ft = { 'oil', 'harpoon', 'alpha', 'dashboard' }
          return not vim.tbl_contains(excluded_ft, vim.bo[buf].filetype)
        end,
      })
    end,
    desc = 'Automatic file saving'
  },

  {
    'psliwka/vim-smoothie',
    lazy = false,
    keys = { '<C-d>', '<C-u>', '<C-f>', '<C-b>' },
    desc = 'Smooth scrolling'
  },

  {
    'wesQ3/vim-windowswap',
    keys = {
      { '<Leader>ww', '<cmd>WindowSwap<cr>', desc = 'Window: Swap' },
    },
    desc = 'Swap windows without layout disruption'
  },

  {
    'wellle/visual-split.vim',
    keys = {
      { '<C-w>gr', mode = 'x', desc = 'Split: Visual selection right' },
      { '<C-w>gb', mode = 'x', desc = 'Split: Visual selection below' },
      { '<C-w>gR', mode = 'x', desc = 'Split: Visual selection above' },
      { '<C-w>gL', mode = 'x', desc = 'Split: Visual selection left' },
    },
    desc = 'Control splits with visual selections'
  },

  {
    'wsdjeg/vim-fetch',
    event = 'VimEnter',
    desc = 'Handle file:line:col syntax'
  },

  {
    'tpope/vim-sleuth',
    event = 'BufReadPost',
    desc = 'Automatic indentation detection'
  },

  {
    'rcarriga/nvim-notify',
    desc = 'Enhanced notification system'
  },

  -- === EDITING ENHANCEMENTS ===
  {
    'tpope/vim-repeat',
    keys = { { '.', desc = 'Repeat last command' } },
    desc = 'Enhanced repeat functionality'
  },

  {
    'inkarkat/vim-visualrepeat',
    dependencies = { 'tpope/vim-repeat' },
    keys = { { '.', mode = 'x', desc = 'Repeat in visual mode' } },
    desc = 'Visual mode repeat support'
  },

  {
    'tpope/vim-rsi',
    event = { 'InsertEnter', 'CmdlineEnter' },
    desc = 'Readline keybindings in insert/command mode'
  },

  {
    'AndrewRadev/splitjoin.vim',
    keys = {
      { 'gS', desc = 'Split: Single to multi-line' },
      { 'gJ', desc = 'Join: Multi to single-line' },
    },
    desc = 'Toggle between single/multi-line statements'
  },

  {
    'RRethy/vim-illuminate',
    event = { 'BufReadPost', 'BufNewFile' },
    desc = 'Highlight word under cursor'
  },

  {
    'jordwalke/VimSplitBalancer',
    lazy = false,
    desc = 'Distribute space among vertical splits'
  },

  {
    'moll/vim-bbye',
    lazy = false,
    keys = {
      { '<Leader>bd', '<cmd>Bdelete<cr>',  desc = 'Delete buffer (preserve layout)' },
      { '<Leader>bD', '<cmd>Bdelete!<cr>', desc = 'Delete buffer (force)' },
    },
    desc = 'Delete buffers without closing windows'
  },

  {
    'gbprod/stay-in-place.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {},
    desc = 'Prevent cursor movement during shift/filter actions'
  },

  { "svban/YankAssassin.vim", event = "VeryLazy", desc = "After yank leave cursor in its place" },

  {
    'folke/trouble.nvim',
    cmd = { 'Trouble', 'TroubleToggle' },
    keys = {
      { '<Leader>tt', '<cmd>Trouble<cr>',                       desc = 'Trouble: Toggle' },
      { '<Leader>tw', '<cmd>Trouble workspace_diagnostics<cr>', desc = 'Trouble: Workspace diagnostics' },
      { '<Leader>tD', '<cmd>Trouble document_diagnostics<cr>',  desc = 'Trouble: Document diagnostics' },
      { '<Leader>tq', '<cmd>Trouble quickfix<cr>',              desc = 'Trouble: Quickfix' },
      { '<Leader>tl', '<cmd>Trouble loclist<cr>',               desc = 'Trouble: Location list' },
      { '<Leader>tr', '<cmd>Trouble lsp_references<cr>',        desc = 'Trouble: LSP references' },
    },
    config = true,
    desc = 'Diagnostics and quickfix list'
  },

  {
    'fei6409/log-highlight.nvim',
    ft = { 'log', 'txt' },
    opts = {},
    desc = 'Syntax highlighting for log files'
  },

  {
    'hrsh7th/nvim-pasta',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      vim.keymap.set({ 'n', 'x' }, 'p', require('pasta.mapping').p, { desc = 'Paste with context' })
      vim.keymap.set({ 'n', 'x' }, 'P', require('pasta.mapping').P, { desc = 'Paste before with context' })
    end,
    desc = 'Context-aware pasting with indentation'
  },
}
