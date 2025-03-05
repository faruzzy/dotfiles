return {
  -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'windwp/nvim-ts-autotag', -- Use treesitter to autoclose and autorename html tags
    'nvim-treesitter/nvim-treesitter-context', -- shows the context of the currently visible buffer contents

    'RRethy/nvim-treesitter-endwise', -- plugin that helps to end certain structures automatically.
    'RRethy/nvim-treesitter-textsubjects',
  },
  build = ':TSUpdate',
  init = function()
    -- Use bash parser for ZSH files
    vim.treesitter.language.register('bash', 'zsh')
  end,

  config = function()
    require('nvim-ts-autotag').setup()
    ---@diagnostic disable-next-line: missing-fields
    require('nvim-treesitter.configs').setup({
      ensure_installed = {
        'html',
        'c',
        'cpp',
        'go',
        'lua',
        'python',
        'pem',
        'rust',
        'tsx',
        'javascript',
        'typescript',
        'vimdoc',
        'vim',
        'bash',
        'diff',
        'git_rebase',
        'git_config',
        'gitcommit',
        'c_sharp',
        'comment',
        'cpp',
        'css',
        'scss',
        'dockerfile',
        'graphql',
        'java',
        'jsdoc',
        'json',
        'toml',
        'jsonc',
        'latex',
        'tmux',
        'readline',
        'markdown',
        'markdown_inline',
        'regex',
        'ruby',
        'vue',
        'yaml',
        'smithy',
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-n>',
          node_incremental = '<c-n>',
          scope_incremental = '<c-s>',
          node_decremental = '<c-r>',
          -- init_selection = '<C-Space>',
          -- node_incremental = '<C-Space>',
          -- node_decremental = '<BS>',
        },
      },

      endwise = {
        enable = true,
      },

      textsubjects = {
        enable = true,
        prev_selection = ',',
        keymaps = {
          ['.'] = 'textsubjects-smart',
          [';'] = 'textsubjects-container-outer',
          ['i;'] = { 'textsubjects-container-inner', desc = 'Select inside containers (classes, functions, etc.)' },
        },
      },

      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']f'] = '@function.outer',
            [']]'] = '@class.outer',
          },
          goto_next_end = {
            [']F'] = '@function.outer',
            [']['] = '@class.outer',
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[['] = '@class.outer',
          },
          goto_previous_end = {
            ['[F'] = '@function.outer',
            ['[]'] = '@class.outer',
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['<leader>a'] = '@parameter.inner',
          },
          swap_previous = {
            ['<leader>A'] = '@parameter.inner',
          },
        },
      },
    })
  end,
}
