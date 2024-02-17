-- [[ Prevent auto comment on <CR> ]]
local no_auto_comment = vim.api.nvim_create_augroup('no_auto_comment', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  command = 'setlocal formatoptions-=r formatoptions-=o',
  group = no_auto_comment
})

-- [[ Highlight on yank ]]
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

