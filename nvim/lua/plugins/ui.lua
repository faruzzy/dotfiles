return {
  {
    'psliwka/vim-smoothie',
    lazy = false,
    keys = { '<C-d>', '<C-u>', '<C-f>', '<C-b>' },
    desc = 'Smooth scrolling',
  },

  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    opts = {
      cmdline = {
        view = 'cmdline_popup',
        format = {
          search_down = { icon = ' ' },
          search_up = { icon = ' ' },
        },
      },
      messages = { view_search = false },
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
      routes = {
        { filter = { event = 'msg_show', kind = '', find = 'written' }, opts = { skip = true } },
        { filter = { event = 'msg_show', kind = 'search_count' }, view = 'mini' },
        { filter = { warning = true, find = 'deprecated' }, opts = { skip = true } },
        { filter = { find = 'deprecated' }, opts = { skip = true } },
        { filter = { event = 'notify', find = 'quit with exit code' }, opts = { skip = true } },
      },
      presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
    desc = 'UI for messages, cmdline, and popupmenu',
  },

  {
    'RRethy/vim-illuminate',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      providers = { 'lsp', 'regex' },
    },
    config = function(_, opts) require('illuminate').configure(opts) end,
    desc = 'Highlight word under cursor',
  },

  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    keys = {
      { '<Leader>tt', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Trouble: Toggle' },
      {
        '<Leader>tw',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Trouble: Workspace diagnostics',
      },
      {
        '<Leader>tD',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Trouble: Document diagnostics',
      },
      { '<Leader>tq', '<cmd>Trouble qflist toggle<cr>', desc = 'Trouble: Quickfix' },
      { '<Leader>tl', '<cmd>Trouble loclist toggle<cr>', desc = 'Trouble: Location list' },
      { '<Leader>tr', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', desc = 'Trouble: LSP references' },
    },
    config = true,
    desc = 'Diagnostics and quickfix list',
  },
}
