return {
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'echasnovski/mini.icons' },
    event = 'VeryLazy',
    opts = {
      winopts = {
        backdrop = 100,
        border = vim.g.border_style,
        preview = { border = 'border-double', wrap = 'wrap', flip_columns = 160 },
      },
      previewers = {
        git_diff = { pager = 'delta --file-style="omit" --hunk-header-style="omit"' },
      },
      fzf_opts = {
        ['--border'] = 'none',
        ['--cycle'] = true,
        ['--marker'] = '+',
        ['--pointer'] = '>',
      },
      grep = {
        rg_opts = table.concat({
          -- custom opts
          '--hidden',
          '-g="!.git"',
          -- default opts
          '--column',
          '--line-number',
          '--no-heading',
          '--color=always',
          '--smart-case',
          '--max-columns=4096',
          '-e',
        }, ' '),
      },
      keymap = {
        builtin = {
          true,
          ['<F1>'] = 'toggle-help',
          ['<F2>'] = 'toggle-fullscreen',
          ['<C-c>'] = 'toggle-preview',
          ['<C-f>'] = 'preview-page-down',
          ['<C-b>'] = 'preview-page-up',
        },
        fzf = {
          true,
          ['alt-a'] = 'toggle-all',
          ['ctrl-q'] = 'select-all+accept',
          ['ctrl-c'] = 'toggle-preview',
          ['ctrl-a'] = 'beginning-of-line',
          ['ctrl-e'] = 'end-of-line',
          ['ctrl-f'] = 'preview-page-down',
          ['ctrl-b'] = 'preview-page-up',
        },
        lsp = {
          code_actions = { previewer = 'codeaction_native' },
          ignore_current_line = true,
          includeDeclaration = false,
        },
        oldfiles = { cwd_only = true },
      },
    },
    keys = {
      {
        '<C-p>',
        function()
          require('fzf-lua').files({ file_icons = false, git_icons = false })
        end,
        desc = 'files / git files',
      },
      {
        '<C-f>',
        [[<cmd>lua require('fzf-lua').grep_project({ file_icons=false, git_icons=false })<CR>]],
        desc = 'file lines',
      },
      --- Buffer
      { '<Leader><CR>', [[<cmd>lua require('fzf-lua').buffers()<CR>]], desc = 'buffers' },
      { '<C-g>', [[<cmd>lua require('fzf-lua').resume()<CR>]], desc = 'resume' },
      { '<leader>of', [[<cmd>lua require('fzf-lua').oldfiles()<CR>]], desc = '[O]ld [F]iles' },

      --- Search
      { '<leader>/', [[<cmd>lua require('fzf-lua').lgrep_curbuf()<CR>]], desc = 'Search current buffer Lines' },
      {
        '<leader>fw',
        [[<cmd>lua require('fzf-lua').grep_cword()<CR>]],
        desc = 'Search word under the cursor globally',
      },
      {
        '<leader>fW',
        [[<cmd>lua require('fzf-lua').grep_cWORD()<CR>]],
        desc = 'Search word under the cursor in current buffer',
      },

      --- Code Navigation
      { '<Leader>dw', [[<cmd>lua require('fzf-lua').diagnostics_workspace()<CR>]], desc = 'Workspace diagnostics' },
      { '<Leader>ws', [[<cmd>lua require('fzf-lua').lsp_workspace_symbols()<CR>]], desc = 'Workspace Symbols' },
      { '<Leader>ds', [[<cmd>lua require('fzf-lua').lsp_document_symbols()<CR>]], desc = 'Document Symbols' },
      {
        'gr',
        [[<cmd>lua require('fzf-lua').lsp_references({ jump_to_single_result = true })<CR>]],
        desc = '[G]o to [R]eferences',
      },
      {
        'gd',
        [[<cmd>lua require('fzf-lua').lsp_definitions({ jump_to_single_result = true })<CR>]],
        desc = '[G]o to [D]efinition',
      },
      {
        'gi',
        [[<cmd>lua require('fzf-lua').lsp_implementations({ jump_to_single_result = true })<CR>]],
        desc = '[G]o to [I]mplementation',
      },
      {
        'D',
        [[<cmd>lua require('fzf-lua').lsp_implementations({ jump_to_single_result = true })<CR>]],
        desc = 'Type Definition',
      },

      --- Git
      { '<Leader>gx', [[<cmd>lua require('fzf-lua').git_commits()<CR>]], desc = 'git commits' },
      { '<Leader>gX', [[<cmd>lua require('fzf-lua').git_bcommits()<CR>]], desc = 'git buffer commits' },
      { '<Leader>gS', [[<cmd>lua require('fzf-lua').git_status()<CR>]], desc = 'git status' },

      --- Misc
      { '<Leader>k', [[<cmd>lua require('fzf-lua').keymaps()<CR>]], desc = 'keymaps' },
      { '<Leader>m', [[<cmd>lua require('fzf-lua').marks()<CR>]], desc = 'marks' },
      {
        '<Leader>hi',
        [[<cmd>lua require('fzf-lua').command_history()<CR>]],
        desc = 'command history',
      },
      { [[<Leader>"]], [[<cmd>lua require('fzf-lua').registers()<CR>]], desc = 'registers' },
      { '<Leader>:', [[<cmd>lua require('fzf-lua').commands()<CR>]], desc = 'vim commands' },
      { '<leader>sh', [[<cmd>lua require('fzf-lua').help_tags()<CR>]], desc = 'help tags' },
      { '<leader>au', [[<cmd>lua require('fzf-lua').autocmds()<CR>]], desc = 'autocmds' },
    },
    init = function()
      local utils = require('utils')

      -- TODO: Implement this section for lsp commands
      -- utils.augroup('fzf_lsp_attach', {
      --   {
      --     'LspAttach',
      --     callback = function(args)
      --       local maps = {
      --         gr = 'lsp_references jump_to_single_result=true',
      --         gpr = 'lsp_references',
      --         gd = 'lsp_definitions jump_to_single_result=true',
      --         gpd = 'lsp_definitions',
      --         gi = 'lsp_implementations jump_to_single_result=true',
      --         gpi = 'lsp_implementations',
      --         ['g*'] = 'lsp_finder',
      --       }

      --       local bsk = utils.buffer_map(args.buf)
      --       for key, cmd in pairs(maps) do
      --         -- bsk('n', key, '<cmd>FzfLua ' .. cmd .. '()<CR>')
      --         -- bsk('n', key, [[<cmd>lua require('fzf-lua').lsp_references({ jump_to_single_result = true })<CR>]])
      --       end
      --     end,
      --   },
      -- })
    end,
  },
}
