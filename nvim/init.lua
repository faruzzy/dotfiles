_G.MY_CONFIG = require('config_variables')
require('faruzzy.settings')
require('faruzzy.remap')
require('faruzzy.autocmd')

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {
  change_detection = { notify = false },
  checker = { enabled = true, notify = false },
  ui = {},
})


