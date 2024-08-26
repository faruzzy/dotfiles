-- Easy motion like plugin that allows you to jump anywhere in a document
return {
  'smoka7/hop.nvim',
  version = '*',
  opts = {
    keys = 'etovxqpdygfblzhckisuran',
  },
  keys = {
    -- This command prompts you to type one key, and will hint that key in the buffer.
    { '<leader>,', '<cmd>HopChar1<cr>', desc = 'Hop to character' },
  },
}
