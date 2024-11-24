-- Plugin for searching and replacing globally
-- Press '?' once the search word and replace word have been set

return {
  'nvim-pack/nvim-spectre',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', {
      desc = 'Toggle Spectre',
    })
    vim.keymap.set('n', '<leader>srw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
      desc = 'Search and replace current word',
    })
    vim.keymap.set('v', '<leader>srw', '<cmd>lua require("spectre").open_visual()<CR>', {
      desc = 'Search and replace current word',
    })
    vim.keymap.set('n', '<leader>sf', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
      desc = 'Search and replace in current file',
    })
  end,
}
