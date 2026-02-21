return {
  {
    'tpope/vim-fugitive',
    dependencies = { 'tpope/vim-rhubarb' },
    cmd = { 'Git' },
    keys = {
      { '<Leader>ga', '<cmd>execute "silent !git add " . shellescape(expand("%:p"))<CR>', desc = 'Git: Add current file' },
      { '<Leader>gp', '<cmd>Git pull<cr>',                                                desc = 'Git: Pull' },
      { '<Leader>gP', '<cmd>Git push<cr>',                                                desc = 'Git: Push' },
      { 'g<cr>',      '<cmd>Git<cr>',                                                     desc = 'Git: Status' },
      { '<Leader>gc', '<cmd>Git commit<cr>',                                              desc = 'Git: Commit' },
      { '<Leader>gd', '<cmd>Gvdiffsplit!<cr>',                                            desc = 'Git: Diff split' },
      { '<Leader>gr', '<cmd>Gvdiffsplit! HEAD~1<cr>',                                     desc = 'Git: Reversed diff of most recent commit' },
      { '<Leader>gb', '<cmd>Git blame<cr>',                                               desc = 'Git: Blame' },
      { '<Leader>gl', '<cmd>Git log --oneline<cr>',                                       desc = 'Git: Log' },
    },
    desc = 'Git wrapper with comprehensive commands'
  },

  {
    'junegunn/gv.vim',
    dependencies = { 'tpope/vim-fugitive' },
    keys = {
      { '<Leader>gv', '<cmd>GV<cr>',  desc = 'Git: Commit browser' },
      { '<Leader>gV', '<cmd>GV!<cr>', desc = 'Git: Commit browser (current file)' },
    },
    desc = 'Git commit browser'
  },

  {
    'rhysd/git-messenger.vim',
    cmd = 'GitMessenger',
    keys = {
      { '<Leader>gm', '<cmd>GitMessenger<cr>', desc = 'Git: Show commit message' },
    },
    desc = 'Show git commit message in popup'
  },

  {
    'wintermute-cell/gitignore.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    cmd = 'Gitignore',
    keys = {
      { '<Leader>gi', '<cmd>Gitignore<cr>', desc = 'Generate .gitignore' },
    },
    desc = 'Generate .gitignore files'
  },
}
