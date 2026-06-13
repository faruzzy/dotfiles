return {
  'folke/todo-comments.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { ']t', function() require('todo-comments').jump_next() end, desc = 'Next TODO comment' },
    { '[t', function() require('todo-comments').jump_prev() end, desc = 'Previous TODO comment' },
    { '<Leader>td', '<cmd>Trouble todo toggle<cr>', desc = 'Trouble: TODOs' },
    { '<Leader>tb', '<cmd>Trouble todo toggle filter.buf=0<cr>', desc = 'Trouble: Buffer TODOs' },
    { '<Leader>st', '<cmd>TodoFzfLua<cr>', desc = 'Search TODOs (fzf)' },
  },
  opts = {},
}
