-- Jump out of surrounding delimiters in insert mode
return {
  'ysmb-wtsg/in-and-out.nvim',
  keys = {
    {
      '<C-]>',
      function() require('in-and-out').in_and_out() end,
      mode = 'i',
      desc = 'Jump out of surrounding delimiter',
    },
  },
  opts = {},
}
