-- Distraction-free writing for Neovim
local M = {
  'Pocco81/true-zen.nvim',
}

function M.config()
  local truezen = require('true-zen')
  truezen.setup({})

  vim.keymap.set('n', '<leader>za', truezen.ataraxis, { noremap = true })
  vim.keymap.set('n', '<leader>zf', truezen.focus, { noremap = true })

  vim.keymap.set('n', '<leader>zn', function()
    local first = 0
    local last = vim.api.nvim_buf_line_count(0)
    truezen.narrow(first, last)
  end, { noremap = true })

  vim.keymap.set('v', '<leader>zn', function()
    local first = vim.fn.line('v')
    local last = vim.fn.line('.')
    truezen.narrow(first, last)
  end, { noremap = true })
end

return M
