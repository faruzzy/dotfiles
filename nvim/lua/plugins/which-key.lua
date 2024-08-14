-- Useful plugin to show you pending keybinds.
return {
  'folke/which-key.nvim', opts = {},
  config = function ()
    local which_key = require('which-key')
    which_key.setup()

    which_key.add {
      { '<leader>c', group = '[C]ode' },
      { '<leader>d', group = '[D]ocument' },
      { '<leader>g', group = '[G]it' },
      { '<leader>h', group = 'Git [H]unk' },
      { '<leader>r', group = '[R]ename' },
      { '<leader>s', group = '[S]earch' },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>w', group = '[W]orkspace' },
      { '<leader>',  name = 'VISUAL <leader>', mode = { 'v' } }
    }
  end
}
