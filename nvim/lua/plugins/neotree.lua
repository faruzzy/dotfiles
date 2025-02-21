-- Neovim plugin to browse the file system and other tree like structures
return {
  'nvim-neo-tree/neo-tree.nvim',
  cmd = 'Neotree',
  branch = 'v2.x',
  keys = {
    { '<C-c>', '<cmd>Neotree toggle<cr>', desc = 'Neotree' },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  config = function()
    require('neo-tree').setup({
      close_if_last_window = true,
      filesystem = {
        follow_current_file = true,
        hijack_netrw_behavior = 'open_current',
      },
    })
  end,
}
