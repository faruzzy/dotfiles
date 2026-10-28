-- Save the session (buffers, tabs, splits) per directory and git branch on exit,
-- and restore it when nvim starts without file arguments
return {
  'folke/persistence.nvim',
  lazy = false,
  init = function()
    vim.opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' }

    -- Registered here (before alpha's config) so the restore runs first; alpha then sees a non-empty buffer
    vim.api.nvim_create_autocmd('VimEnter', {
      group = vim.api.nvim_create_augroup('persistence_autoload', { clear = true }),
      nested = true, -- let FileType/LSP autocmds fire for restored buffers
      callback = function()
        if vim.fn.argc() > 0 or vim.g.started_with_stdin then return end
        local persistence = require('persistence')
        -- Only this branch's own session: load() would fall back to the main/master one on a new branch
        if vim.fn.filereadable(persistence.current()) == 0 then return end
        -- Wait until startup is done: sourced inside VimEnter, the first file's FileType never fires
        vim.schedule(function() persistence.load() end)
      end,
    })
    vim.api.nvim_create_autocmd('StdinReadPre', {
      group = vim.api.nvim_create_augroup('persistence_stdin', { clear = true }),
      callback = function() vim.g.started_with_stdin = true end,
    })

    -- A saved neo-tree window comes back as an empty split; close it before saving
    vim.api.nvim_create_autocmd('User', {
      group = vim.api.nvim_create_augroup('persistence_neotree', { clear = true }),
      pattern = 'PersistenceSavePre',
      callback = function()
        if package.loaded['neo-tree'] then pcall(vim.cmd, 'Neotree close') end
      end,
    })
  end,
  opts = { branch = true },
  keys = {
    { '<Leader>qs', function() require('persistence').load() end, desc = 'Session: restore for this directory' },
    { '<Leader>qS', function() require('persistence').select() end, desc = 'Session: pick one' },
    { '<Leader>ql', function() require('persistence').load({ last = true }) end, desc = 'Session: restore last' },
    { '<Leader>qd', function() require('persistence').stop() end, desc = "Session: don't save on exit" },
  },
}
