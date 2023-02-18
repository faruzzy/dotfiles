local augroup = require('utils').augroup

augroup('no_auto_comment', {
  { 'FileType', { command = 'setlocal formatoptions-=r formatoptions-=o' } },
})
