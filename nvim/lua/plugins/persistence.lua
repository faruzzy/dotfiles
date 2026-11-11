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

    -- A saved neo-tree window comes back as an empty split, so close it before saving and
    -- reopen it after loading. Which tabs had one is stored in NeoTreeSession: 'globals'
    -- writes capitalized string globals into the session file.
    local neotree_group = vim.api.nvim_create_augroup('persistence_neotree', { clear = true })

    local function neotree_restore()
      local ok, state = pcall(vim.json.decode, vim.g.NeoTreeSession or '')
      vim.g.NeoTreeSession = nil
      if not ok or type(state) ~= 'table' then return end
      local function tree_in_tab()
        for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == 'neo-tree' then return true end
        end
        return false
      end
      local win, tabs = vim.api.nvim_get_current_win(), vim.api.nvim_list_tabpages()
      for _, nr in ipairs(state.tabs) do
        if tabs[nr] then
          vim.api.nvim_set_current_tabpage(tabs[nr])
          -- Not 'Neotree show': it later jumps back to the previous window, which after a tab
          -- switch is in another tab, so the next tab's tree would open there instead
          vim.cmd('Neotree focus')
          vim.wait(1000, tree_in_tab, 10)
        end
      end
      vim.api.nvim_set_current_win(win)
      if state.focused then vim.cmd('Neotree focus') end
    end

    -- getbufinfo's lastused has 1s resolution, so track the last file buffer entered
    local last_file
    vim.api.nvim_create_autocmd('BufEnter', {
      group = neotree_group,
      callback = function(args)
        if vim.bo[args.buf].buftype == '' and args.file ~= '' then last_file = args.buf end
      end,
    })
    vim.api.nvim_create_autocmd('User', {
      group = neotree_group,
      pattern = 'PersistenceSavePre',
      callback = function()
        -- The file you were last in, for a tree that is the last window in its tab
        local function recent_file()
          if last_file and vim.api.nvim_buf_is_valid(last_file) and vim.bo[last_file].buflisted then return last_file end
          local bufs = vim.tbl_filter(
            function(b) return vim.bo[b.bufnr].buftype == '' and b.name ~= '' end,
            vim.fn.getbufinfo({ buflisted = 1 })
          )
          table.sort(bufs, function(a, b) return a.lastused > b.lastused end)
          return bufs[1] and bufs[1].bufnr
        end
        local tabs, focused, cur = {}, false, vim.api.nvim_get_current_win()
        for nr, tab in ipairs(vim.api.nvim_list_tabpages()) do
          for _, w in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
            if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == 'neo-tree' then
              if tabs[#tabs] ~= nr then tabs[#tabs + 1] = nr end
              -- :q in the last file window leaves the tree alone, and close_if_last_window quits
              -- from there; the last window can't be closed, so show a file in it instead
              local splits = vim.tbl_filter(
                function(x) return vim.api.nvim_win_get_config(x).relative == '' end,
                vim.api.nvim_tabpage_list_wins(tab)
              )
              local buf = #splits == 1 and recent_file()
              if buf then
                vim.api.nvim_win_set_buf(w, buf)
              else
                focused = focused or w == cur
                pcall(vim.api.nvim_win_close, w, false)
              end
            end
          end
        end
        vim.g.NeoTreeSession = #tabs > 0 and vim.json.encode({ tabs = tabs, focused = focused }) or nil
      end,
    })
    -- A save while still editing (not on exit) shouldn't leave the tree closed
    vim.api.nvim_create_autocmd('User', {
      group = neotree_group,
      pattern = 'PersistenceSavePost',
      callback = function()
        if vim.v.exiting == vim.NIL then neotree_restore() else vim.g.NeoTreeSession = nil end
      end,
    })
    vim.api.nvim_create_autocmd('User', {
      group = neotree_group,
      pattern = 'PersistenceLoadPost',
      callback = function() vim.schedule(neotree_restore) end,
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
