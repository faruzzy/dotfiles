  -- Easy motion like plugin that allows you to jump anywhere in a document
return {
  'phaazon/hop.nvim',
  branch = 'v2', -- optional but strongly recommended
  config = function()
    -- you can configure Hop the way you like here; see :h hop-config
    require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }

    -- This command prompts you to type one key, and will hint that key in the buffer.
    vim.keymap.set('n', '<leader>,', ':HopChar1<cr>')
  end
}
