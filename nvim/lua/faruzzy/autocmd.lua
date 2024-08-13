local augroup = require('utils').augroup

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

local spell_group = vim.api.nvim_create_augroup('spell_group', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'gitcommit,markdown',
  command = 'setlocal spell',
  group = spell_group,
})

augroup('mode_highlights', {
  {
    'ModeChanged',
    callback = function()
      require('modes').relink_highlights()
      require('tint').refresh()
    end,
  },
})
