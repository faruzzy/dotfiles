-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local M = {
  'nvim-telescope/telescope.nvim',
  version = '*',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available. Make sure you have the system
    -- requirements installed.
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      -- NOTE: If you are having trouble with this installation,
      -- refer to the README for telescope-fzf-native for more instructions.
      build = 'make',
      cond = function()
	return vim.fn.executable 'make' == 1
      end,
    },
    -- extension that offers intelligent prioritization when selecting files from your editing history.
    --[[ {
      'nvim-telescope/telescope-frecency.nvim',
      config = function() require('telescope').load_extension('frecency') end,
    }, ]]
    },
}

function M.config()
  local telescope = require 'telescope'
  local actions = require 'telescope.actions'
  local action_set = require 'telescope.actions.set'

  telescope.setup({
    defaults = {
      mappings = {
	i = {
	  -- ['<Tab>'] = actions.toggle_selection + actions.move_selection_next,
	  ['<C-u>'] = false,
	  ['<C-d>'] = false,
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
      },
    },
    pickers = {
      find_files = {
	hidden = true,
	find_command = {'rg', '--files', '--hidden', '-g', '!.git' }
      },
      buffers = {
	initial_mode = 'normal',
	sort_lastused = true,
	sort_mru = true,
      },
    },
  })

  vim.keymap.set('n', '<C-p>', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<C-g>', '<cmd>Telescope resume<CR>') -- useful for running the last global grep search
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

  telescope.load_extension('fzf')
  -- telescope.load_extension('frecency')
  telescope.load_extension('notify')
end

return M
