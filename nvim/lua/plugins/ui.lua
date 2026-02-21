return {
  {
    'psliwka/vim-smoothie',
    lazy = false,
    keys = { '<C-d>', '<C-u>', '<C-f>', '<C-b>' },
    desc = 'Smooth scrolling'
  },

  {
    'rcarriga/nvim-notify',
    desc = 'Enhanced notification system'
  },

  {
    'RRethy/vim-illuminate',
    event = { 'BufReadPost', 'BufNewFile' },
    desc = 'Highlight word under cursor'
  },

  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    keys = {
      { '<Leader>tt', '<cmd>Trouble diagnostics toggle<cr>',                        desc = 'Trouble: Toggle' },
      { '<Leader>tw', '<cmd>Trouble diagnostics toggle<cr>',                        desc = 'Trouble: Workspace diagnostics' },
      { '<Leader>tD', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',           desc = 'Trouble: Document diagnostics' },
      { '<Leader>tq', '<cmd>Trouble qflist toggle<cr>',                             desc = 'Trouble: Quickfix' },
      { '<Leader>tl', '<cmd>Trouble loclist toggle<cr>',                            desc = 'Trouble: Location list' },
      { '<Leader>tr', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', desc = 'Trouble: LSP references' },
    },
    config = true,
    desc = 'Diagnostics and quickfix list'
  },
}
