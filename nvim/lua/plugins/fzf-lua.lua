return {
  { 'junegunn/fzf', dir = '~/.fzf', build = './install --bin' },
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'echasnovski/mini.icons' },
    opts = {
      winopts = {
        backdrop = 100,
        border = vim.g.border_style,
        preview = { border = 'sharp', wrap = 'wrap', flip_columns = 160 },
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
      { '<C-r>', [[<cmd>lua require('fzf-lua').buffers()<CR>]], desc = 'buffers' },
      { '<C-g>', [[<cmd>lua require('fzf-lua').resume()<CR>]], desc = 'marks' },
      { '<leader>?', [[<cmd>lua require('fzf-lua').oldfiles()<CR>]], desc = 'buffers' },

      --- Search
      { '<leader>/', [[<cmd>lua require('fzf-lua').lgrep_curbuf()<CR>]], desc = 'buffer Lines' },
      { '<leader>fw', [[<cmd>lua require('fzf-lua').grep_cword()<CR>]], desc = 'buffer Lines' },
      { '<leader>fW', [[<cmd>lua require('fzf-lua').grep_cWORD()<CR>]], desc = 'buffer Lines' },

      --- Code Navigation
      { '<leader>wd', [[<cmd>lua require('fzf-lua').diagnostics_workspace()<CR>]], desc = 'Workspace diagnostics' },
      { '<leader>ws', [[<cmd>lua require('fzf-lua').lsp_workspace_symbols()<CR>]], desc = 'Workspace Symbols' },
      { '<leader>ds', [[<cmd>lua require('fzf-lua').lsp_document_symbols()<CR>]], desc = 'Document Symbols' },

      --- Git
      { '<Leader>gl', [[<cmd>lua require('fzf-lua').git_commits()<CR>]], desc = 'git commits' },
      { '<Leader>gL', [[<cmd>lua require('fzf-lua').git_bcommits()<CR>]], desc = 'git buffer commits' },
      { '<Leader>gS', [[<cmd>lua require('fzf-lua').git_status()<CR>]], desc = 'git status' },

      --- Misc
      { '<Leader>k', [[<cmd>lua require('fzf-lua').keymaps()<CR>]], desc = 'keymaps' },
      { '<Leader>m', [[<cmd>lua require('fzf-lua').marks()<CR>]], desc = 'marks' },
      {
        '<Leader>h',
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

      utils.augroup('fzf_lsp_attach', {
        {
          'LspAttach',
          callback = function(args)
            local maps = {
              gr = 'lsp_references jump_to_single_result=true',
              gpr = 'lsp_references',
              gd = 'lsp_definitions jump_to_single_result=true',
              gpd = 'lsp_definitions',
              gi = 'lsp_implementations jump_to_single_result=true',
              gpi = 'lsp_implementations',
              ['g*'] = 'lsp_finder',
            }

            local bsk = utils.buffer_map(args.buf)
            for key, cmd in pairs(maps) do
              bsk('n', key, '<cmd>FzfLua ' .. cmd .. '<CR>')
            end
          end,
        },
      })
    end,
  },
}
