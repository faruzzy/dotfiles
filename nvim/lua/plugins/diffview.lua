-- Cycling through diffs for all modified files for any git rev
return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  init = function()
    -- :PRReview 123 opens that PR; without a number, pick from open PRs
    vim.api.nvim_create_user_command('PRReview', function(opts)
      local pr = require('config.pr_review')
      if opts.args == '' then pr.pick() else pr.open(opts.args) end
    end, { nargs = '?', desc = 'Review a GitHub PR in diffview' })
  end,
  keys = {
    { '<leader>dp', function() require('config.pr_review').pick() end, desc = 'Review a GitHub PR in diffview' },
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
      '<leader>dV',
      function()
        if require('diffview.lib').get_current_view() then
          return vim.cmd.DiffviewClose()
        end
        -- Default branch from origin/HEAD (main or master), falling back to whichever exists
        local base = vim.trim(vim.fn.system({ 'git', 'rev-parse', '--abbrev-ref', 'origin/HEAD' }))
        if vim.v.shell_error ~= 0 then
          base = nil
          for _, candidate in ipairs({ 'origin/main', 'origin/master' }) do
            vim.fn.system({ 'git', 'rev-parse', '--verify', '--quiet', candidate })
            if vim.v.shell_error == 0 then
              base = candidate
              break
            end
          end
        end
        if not base then
          return vim.notify('No origin/HEAD, origin/main or origin/master to compare against', vim.log.levels.WARN)
        end
        -- Branch point to the files on disk: committed and uncommitted work, without main's newer changes
        vim.cmd(('DiffviewOpen %s...HEAD --imply-local'):format(base))
      end,
      desc = 'Toggle Diffview of the whole branch (incl. uncommitted)',
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
    { '<leader>dc', '<cmd>DiffviewClose<cr>', desc = 'Close Diffview' },
    { '<leader>dr', '<cmd>DiffviewRefresh<cr>', desc = 'Refresh Diffview' },
  },
  opts = {
    enhanced_diff_hl = true, -- Use better diff highlighting
    view = {
      -- Revision and path at the top of each side (incline hides its label on diffview:// buffers)
      default = { winbar_info = true },
      merge_tool = {
        layout = 'diff3_mixed', -- Better 3-way merge view
      },
    },
    file_panel = {
      win_config = { width = 50 }, -- the default 35 cuts off nested e2e/src paths
    },
    hooks = {
      diff_buf_read = function()
        vim.opt_local.wrap = false
        vim.opt_local.list = false
      end,
    },
  },
}
