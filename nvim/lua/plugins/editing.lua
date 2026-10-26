return {
  {
    'farmergreg/vim-lastplace',
    event = 'BufReadPost',
    desc = 'Intelligently reopen files at last edit position',
  },

  { 'lewis6991/spaceless.nvim', event = 'BufReadPost' },

  (function()
    local excluded = { 'oil', 'harpoon', 'alpha', 'dashboard', 'fugitive' }
    -- tsx/jsx get their own slower idle save (below) so format-on-save doesn't churn mid-edit
    local jsx_filetypes = { typescriptreact = true, javascriptreact = true }
    local jsx_idle_ms = 2000

    local function can_save(buf)
      if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= '' then
        return false
      end
      local name = vim.api.nvim_buf_get_name(buf)
      -- Writing a Fugitive index/blob buffer stages it; leave that to an explicit :w
      if name == '' or name:match('^fugitive://') then
        return false
      end
      -- Sync with disk before saving so an external edit (e.g. Claude Code)
      -- isn't overwritten by a stale buffer. If the file changed on disk,
      -- Neovim will prompt and skip the write.
      pcall(vim.cmd, 'checktime ' .. buf)
      return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modified
    end

    local function setup_jsx_idle_save()
      local timers = {}
      local function cancel(buf)
        local timer = timers[buf]
        if timer then
          timer:stop()
          timer:close()
          timers[buf] = nil
        end
      end

      local group = vim.api.nvim_create_augroup('jsx_idle_save', { clear = true })
      vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged' }, {
        group = group,
        callback = function(args)
          local buf = args.buf
          if not jsx_filetypes[vim.bo[buf].filetype] then
            return
          end
          cancel(buf)
          local timer = assert(vim.uv.new_timer())
          timers[buf] = timer
          timer:start(jsx_idle_ms, 0, vim.schedule_wrap(function()
            cancel(buf)
            if can_save(buf) then
              vim.api.nvim_buf_call(buf, function() vim.cmd('silent! lockmarks write') end)
            end
          end))
        end,
        desc = 'Save tsx/jsx after 2s idle in normal mode',
      })
      vim.api.nvim_create_autocmd({ 'InsertEnter', 'BufDelete' }, {
        group = group,
        callback = function(args) cancel(args.buf) end,
      })
    end

    return {
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
          local filetype = vim.bo[buf].filetype
          if vim.tbl_contains(excluded, filetype) or jsx_filetypes[filetype] then
            return false
          end
          return can_save(buf)
        end,
        write_all_buffers = false,
        debounce_delay = 500,
      },
      config = function(_, opts)
        require('auto-save').setup(opts)
        setup_jsx_idle_save()
      end,
      desc = 'Auto-save (tsx/jsx: after 2s idle in normal mode)',
    }
  end)(),

  {
    'andythigpen/nvim-coverage',
    cmd = { 'Coverage', 'CoverageLoad', 'CoverageLoadLcov', 'CoverageShow', 'CoverageHide', 'CoverageToggle', 'CoverageClear', 'CoverageSummary' },
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
    cmd = { 'Bdelete', 'Bwipeout' },
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
      -- Filetypes where pasta's context-aware reindent mis-guesses; fall back to default p/P
      local disabled = { lua = true }

      local function paste(key)
        return function()
          if disabled[vim.bo.filetype] then
            local count = vim.v.count > 0 and vim.v.count or ''
            vim.cmd('normal! "' .. vim.v.register .. count .. key)
          else
            require('pasta.mapping')[key]()
          end
        end
      end

      vim.keymap.set({ 'n', 'x' }, 'p', paste('p'), { desc = 'Paste with context' })
      vim.keymap.set({ 'n', 'x' }, 'P', paste('P'), { desc = 'Paste before with context' })
    end,
    desc = 'Context-aware pasting with indentation',
  },
}
