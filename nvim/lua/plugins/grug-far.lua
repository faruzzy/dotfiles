-- Project-wide search and replace (ripgrep) in an editable buffer
return {
  'MagicDuck/grug-far.nvim',
  cmd = { 'GrugFar', 'GrugFarWithin' },
  opts = {},
  keys = {
    {
      '<leader>S',
      function() require('grug-far').toggle_instance({ instanceName = 'far', staticTitle = 'Find and Replace' }) end,
      desc = 'Toggle search and replace',
    },
    {
      '<leader>srw',
      function() require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } }) end,
      desc = 'Search and replace current word',
    },
    {
      '<leader>srw',
      function() require('grug-far').with_visual_selection() end,
      mode = 'v',
      desc = 'Search and replace selection',
    },
    {
      '<leader>sf',
      function() require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>'), paths = vim.fn.expand('%') } }) end,
      desc = 'Search and replace in current file',
    },
  },
}
