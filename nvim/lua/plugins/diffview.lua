-- Cycling through diffs for all modified files for any git rev
return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    {
      '<leader>dv',
      function()
        local lib = require('diffview.lib')
        local view = lib.get_current_view()
        if view then
          vim.cmd.DiffviewClose()
        else
          vim.cmd.DiffviewOpen()
        end
      end,
      desc = 'Toggle Diffview',
    },
    {
      '<leader>dh',
      '<cmd>DiffviewFileHistory %<cr>',
      desc = 'Diffview File History (current file)',
    },
    {
      '<leader>dH',
      '<cmd>DiffviewFileHistory<cr>',
      desc = 'Diffview File History (all)',
    },
    { '<leader>dc', '<cmd>DiffviewClose<cr>',   desc = 'Close Diffview' },
    { '<leader>dr', '<cmd>DiffviewRefresh<cr>', desc = 'Refresh Diffview' },
  },
  opts = {
    enhanced_diff_hl = true, -- Use better diff highlighting
    view = {
      merge_tool = {
        layout = 'diff3_mixed', -- Better 3-way merge view
      },
    },
    hooks = {
      diff_buf_read = function()
        vim.opt_local.wrap = false
        vim.opt_local.list = false
      end,
    },
  },
}
