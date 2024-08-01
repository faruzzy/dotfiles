-- Fuzzy Finder (files, lsp, etc)
local M = {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'jonarrien/telescope-cmdline.nvim',
    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available. Make sure you have the system
    -- requirements installed.
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      config = function () require('telescope').load_extension('fzf') end,
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    {
      'nvim-telescope/telescope-frecency.nvim', -- extension that offers intelligent prioritization
      config = function() require('telescope').load_extension('frecency') end,
    },
  },
}

function M.config()
  local telescope = require 'telescope'
  local actions = require 'telescope.actions'
  local action_set = require 'telescope.actions.set'

  telescope.setup {
    defaults = {
      path_display = { 'truncate' },
      prompt_prefix = '   ',
      entry_prefix = '  ',
      selection_caret = ' ',
      mappings = {
        i = {
          ['<C-u>'] = actions.results_scrolling_up,
          ['<C-d>'] = actions.results_scrolling_down,
          ['<C-j>'] = function(prompt_bufnr)
            action_set.scroll_results(prompt_bufnr, 1)
          end,
          ['<C-k>'] = function(prompt_bufnr)
            action_set.scroll_results(prompt_bufnr, -1)
          end,
          ['<C-f>'] = actions.preview_scrolling_down,
          ['<C-b>'] = actions.preview_scrolling_up,
          ['<C-a>'] = actions.select_all,
        },
        n = {
          ['<C-u>'] = actions.preview_scrolling_up,
          ['<C-d>'] = actions.preview_scrolling_down,
        }
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = 'smart_case',
      }
    },
    pickers = {
      find_files = {
        hidden = true,
        find_command = { 'rg', '--files', '--hidden', '-g', '!.git' }
      },
      buffers = {
        initial_mode = 'normal',
        sort_lastused = true,
        sort_mru = true,
      },
    },
    cmdline = {
      picker = {
        layout_config = {
          width  = 120,
          height = 25,
        }
      },
      mappings    = {
        complete      = '<Tab>',
        run_selection = '<C-CR>',
        run_input     = '<CR>',
      },
    }
  }

  vim.keymap.set('n', '<C-p>', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set('n', '<C-g>', require('telescope.builtin').resume, { desc = 'Search Resume' }) -- useful for running the last global grep search
  vim.keymap.set('n', '<leader>f', '<cmd>Telescope frecency<CR>')
  -- vim.keymap.set('n', '<leader>gs', '<cmd>Telescope git_status<CR>')

  -- See `:help telescope.builtin`
  vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
  vim.keymap.set('n', '<leader><cr>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
  vim.keymap.set('n', '<leader>/', function()

    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer]' })
  vim.api.nvim_set_keymap('n', ':', ':Telescope cmdline<CR>', { noremap = true, desc = "Cmdline" })
end

return M
