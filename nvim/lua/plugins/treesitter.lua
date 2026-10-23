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
        'readline',
        'markdown',
        'markdown_inline',
        'regex',
        'ruby',
        'vue',
        'yaml',
        'smithy',
      }

      local treesitter_indent_filetypes = {
        javascriptreact = true,
        typescriptreact = true,
      }

      local treesitter_highlight_disabled_filetypes = {
        css = true,
      }

      -- Enable treesitter highlighting for all filetypes with a parser
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          if not treesitter_highlight_disabled_filetypes[vim.bo[args.buf].filetype] then
            pcall(vim.treesitter.start, args.buf)
          end
          if treesitter_indent_filetypes[vim.bo[args.buf].filetype] then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

    end,
  },

  {
    -- Textobjects: select, move, swap
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = { 'BufReadPost', 'BufNewFile' },
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
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('treesitter-context').setup({ enable = true })
    end,
  },

  -- Autoclose and autorename HTML tags
  {
    'windwp/nvim-ts-autotag',
    -- Before FileType, so the tsx > override below applies to the first buffer
    event = { 'BufReadPre', 'BufNewFile' },
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
          -- Override autotag's > mapping to skip close_tag in type contexts.
          -- Return '>' as typed input (expr) so it is recorded for . repeat and undo.
          vim.keymap.set('i', '>', function()
            vim.schedule(function()
              if vim.api.nvim_get_current_buf() == args.buf and not in_type_context() then
                require('nvim-ts-autotag.internal').close_tag()
              end
            end)
            return '>'
          end, { buffer = args.buf, expr = true, silent = true })
        end,
      })
    end,
  },

  -- Auto-end structures (do/end, if/end, etc.)
  -- Before FileType, which is when endwise attaches to a buffer
  { 'RRethy/nvim-treesitter-endwise', event = { 'BufReadPre', 'BufNewFile' } },
}
