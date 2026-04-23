return {
  {
    -- Parser management and highlighting
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    init = function()
      vim.treesitter.language.register('bash', 'zsh')
    end,
    config = function()
      require('nvim-treesitter').install {
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
        'css',
        'scss',
        'dockerfile',
        'graphql',
        'java',
        'jsdoc',
        'json',
        'toml',
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
      }

      -- Enable treesitter highlighting for all filetypes with a parser
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })

    end,
  },

  {
    -- Textobjects: select, move, swap
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      }

      -- Select keymaps
      local select = require('nvim-treesitter-textobjects.select')
      vim.keymap.set({ 'x', 'o' }, 'aa', function() select.select_textobject('@parameter.outer', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'ia', function() select.select_textobject('@parameter.inner', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'af', function() select.select_textobject('@function.outer', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'if', function() select.select_textobject('@function.inner', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'ac', function() select.select_textobject('@class.outer', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'ic', function() select.select_textobject('@class.inner', 'textobjects') end)

      -- Move keymaps
      local move = require('nvim-treesitter-textobjects.move')
      vim.keymap.set({ 'n', 'x', 'o' }, ']f', function() move.goto_next_start('@function.outer', 'textobjects') end)
      vim.keymap.set({ 'n', 'x', 'o' }, ']]', function() move.goto_next_start('@class.outer', 'textobjects') end)
      vim.keymap.set({ 'n', 'x', 'o' }, ']F', function() move.goto_next_end('@function.outer', 'textobjects') end)
      vim.keymap.set({ 'n', 'x', 'o' }, '][', function() move.goto_next_end('@class.outer', 'textobjects') end)
      vim.keymap.set({ 'n', 'x', 'o' }, '[f', function() move.goto_previous_start('@function.outer', 'textobjects') end)
      vim.keymap.set({ 'n', 'x', 'o' }, '[[', function() move.goto_previous_start('@class.outer', 'textobjects') end)
      vim.keymap.set({ 'n', 'x', 'o' }, '[F', function() move.goto_previous_end('@function.outer', 'textobjects') end)
      vim.keymap.set({ 'n', 'x', 'o' }, '[]', function() move.goto_previous_end('@class.outer', 'textobjects') end)

      -- Swap keymaps
      local swap = require('nvim-treesitter-textobjects.swap')
      vim.keymap.set('n', '<leader>a', function() swap.swap_next('@parameter.inner') end)
      vim.keymap.set('n', '<leader>A', function() swap.swap_previous('@parameter.inner') end)
    end,
  },

  -- Context (shows function/class context at top of buffer)
  {
    'nvim-treesitter/nvim-treesitter-context',
    config = function()
      require('treesitter-context').setup({ enable = true })
    end,
  },

  -- Autoclose and autorename HTML tags
  {
    'windwp/nvim-ts-autotag',
    config = function()
      require('nvim-ts-autotag').setup({})

      -- Prevent autotag from closing generic type parameters as JSX tags
      -- (e.g. useRef<HTMLInputElement> should not become useRef<HTMLInputElement></HTMLInputElement>)
      local type_nodes = { 'type_arguments', 'type_parameters', 'type_annotation' }
      local function in_type_context()
        local ok, node = pcall(vim.treesitter.get_node)
        if not ok or not node then return false end
        while node do
          if vim.tbl_contains(type_nodes, node:type()) then return true end
          node = node:parent()
        end
        return false
      end

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'typescriptreact', 'javascriptreact' },
        callback = function(args)
          -- Override autotag's > mapping to skip close_tag in type contexts
          vim.keymap.set('i', '>', function()
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            local bufnr = args.buf
            vim.api.nvim_buf_set_text(bufnr, row - 1, col, row - 1, col, { '>' })
            vim.api.nvim_win_set_cursor(0, { row, col + 1 })
            if not in_type_context() then
              vim.schedule(function()
                require('nvim-ts-autotag.internal').close_tag()
              end)
            end
          end, { buffer = args.buf, noremap = true, silent = true })
        end,
      })
    end,
  },

  -- Auto-end structures (do/end, if/end, etc.)
  { 'RRethy/nvim-treesitter-endwise' },
}
