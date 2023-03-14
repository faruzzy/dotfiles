--[[
                                                         ▟▙
                                                         ▝▘
               ██▃▅▇█▆▖  ▗▟████▙▖   ▄████▄     ██▄  ▄██  ██  ▗▟█▆▄▄▆█▙▖
               ██▛▔ ▝██  ██▄▄▄▄██  ██▛▔▔▜██    ▝██  ██▘  ██  ██▛▜██▛▜██
               ██    ██  ██▀▀▀▀▀▘  ██▖  ▗██  █  ▜█▙▟█▛   ██  ██  ██  ██
               ██    ██  ▜█▙▄▄▄▟▊  ▀██▙▟██▀     ▝████▘   ██  ██  ██  ██
               ▀▀    ▀▀   ▝▀▀▀▀▀     ▀▀▀▀         ▀▀     ▀▀  ▀▀  ▀▀  ▀▀
]]--

require 'faruzzy'
--require 'faruzzy.plugins.autoformat'
--vim.g.loaded_netrw = 1
--vim.g.loaded_netrwPugin = 1

-- Install package manager
-- https://github.com/folke/lazy.nvim
-- `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins')

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
