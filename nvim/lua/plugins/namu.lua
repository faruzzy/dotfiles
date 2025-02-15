return {
  'bassamsdata/namu.nvim',
  config = function()
    require('namu').setup({
      -- Enable the modules you want
      namu_symbols = {
        enable = true,
        options = {}, -- here you can configure namu
      },
    })
    -- === Suggested Keymaps: ===
    local namu = require('namu.namu_symbols')
    local colorscheme = require('namu.colorscheme')
    vim.keymap.set('n', '<leader>ss', namu.show, {
      desc = 'Jump to LSP symbol',
      silent = true,
    })
    vim.keymap.set('n', '<leader>th', colorscheme.show, {
      desc = 'Colorscheme Picker',
      silent = true,
    })
  end,
}
