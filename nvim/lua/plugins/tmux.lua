return {
  {
    'christoomey/vim-tmux-navigator',
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    keys = {
      { '<C-h>', '<cmd>TmuxNavigateLeft<cr>',  mode = 'n', desc = 'Navigate Left' },
      { '<C-j>', '<cmd>TmuxNavigateDown<cr>',  mode = 'n', desc = 'Navigate Down' },
      { '<C-k>', '<cmd>TmuxNavigateUp<cr>',    mode = 'n', desc = 'Navigate Up' },
      { '<C-l>', '<cmd>TmuxNavigateRight<cr>', mode = 'n', desc = 'Navigate Right' },
    },
    desc = 'Seamless vim/tmux navigation'
  },

  {
    'benmills/vimux',
    keys = {
      { '<Leader>vr', '<cmd>VimuxPromptCommand<cr>',   desc = 'Vimux: Prompt Command' },
      { '<Leader>vl', '<cmd>VimuxRunLastCommand<cr>',  desc = 'Vimux: Run Last Command' },
      { '<Leader>vi', '<cmd>VimuxInterruptRunner<cr>', desc = 'Vimux: Interrupt Runner' },
      { '<Leader>vc', '<cmd>VimuxCloseRunner<cr>',     desc = 'Vimux: Close Runner' },
      { '<Leader>vz', '<cmd>VimuxZoomRunner<cr>',      desc = 'Vimux: Zoom Runner' },
      { '<Leader>vt', '<cmd>VimuxTogglePane<cr>',      desc = 'Vimux: Toggle Pane' },
    },
    desc = 'Tmux integration for running commands'
  },

  {
    'wellle/tmux-complete.vim',
    event = 'InsertEnter',
    desc = 'Insert mode completion from tmux panes'
  },
}
