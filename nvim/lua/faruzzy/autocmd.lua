local utils = require('utils')
local augroup = utils.augroup

-- Prevent auto-commenting on Enter or o/O
augroup('no_auto_comment', {
  {
    'FileType',
    command = 'setlocal formatoptions-=r formatoptions-=o',
  },
})

-- Re-enable comment continuation for JavaScript/TypeScript to support JSDoc
augroup('jsdoc_comment_continuation', {
  {
    'FileType',
    pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    callback = function(args)
      local bmap = utils.buffer_map(args.buf)
      vim.opt_local.formatoptions:append('ro')
      vim.opt_local.comments = 'sO:* -,mO:*  ,exO:*/,s1:/*,mb:*,ex:*/'

      -- JSDoc auto-expansion on Enter after /**
      bmap('i', '<CR>', function()
        -- Let blink handle CR when completion menu is visible
        local blink_ok, blink = pcall(require, 'blink.cmp')
        if blink_ok and blink.is_visible() then
          return blink.select_and_accept() and '' or require('nvim-autopairs').autopairs_cr()
        end

        local line = vim.api.nvim_get_current_line()
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local col = vim.api.nvim_win_get_cursor(0)[2]
        local before_cursor = line:sub(1, col)

        -- Check if we just typed /**
        if before_cursor:match('^%s*/%*%*$') then
          local indent = before_cursor:match('^(%s*)')

          -- Schedule the buffer modification
          vim.schedule(function()
            -- Insert the JSDoc structure
            vim.api.nvim_buf_set_lines(0, row, row, false, {
              indent .. ' * ',
              indent .. ' */',
            })
            -- Position cursor at the end of the first inserted line
            vim.api.nvim_win_set_cursor(0, { row + 1, #indent + 3 })
          end)
          return ''
        end

        -- Continue block comment with aligned " * " (bypasses smartindent
        -- which mis-indents after lines containing { like @param {type})
        if before_cursor:match('^%s*%*') then
          local prefix = line:match('^(%s*%*)')
          vim.schedule(function()
            vim.api.nvim_buf_set_lines(0, row, row, false, { prefix .. ' ' })
            vim.api.nvim_win_set_cursor(0, { row + 1, #prefix + 1 })
          end)
          return ''
        end

        -- Otherwise use autopairs CR
        return require('nvim-autopairs').autopairs_cr()
      end, { expr = true, replace_keycodes = false })

      -- Same fix for 'o' in normal mode: bypass smartindent inside block comments
      bmap('n', 'o', function()
        local line = vim.api.nvim_get_current_line()
        if line:match('^%s*%*') then
          local prefix = line:match('^(%s*%*)')
          local row = vim.api.nvim_win_get_cursor(0)[1]
          vim.api.nvim_buf_set_lines(0, row, row, false, { prefix .. ' ' })
          vim.api.nvim_win_set_cursor(0, { row + 1, #prefix + 1 })
          vim.cmd('startinsert!')
          return
        end
        vim.api.nvim_feedkeys('o', 'n', false)
      end)
    end,
  },
})

-- Highlight yanked text briefly
augroup('YankHighlight', {
  {
    'TextYankPost',
    callback = function()
      if vim.bo.buftype == '' then
        vim.hl.on_yank({ higroup = 'IncSearch', timeout = 200 })
      end
    end,
    pattern = '*',
  },
})

-- Enable spell-checking for writing-heavy filetypes
augroup('spell_group', {
  {
    'FileType',
    pattern = { 'gitcommit', 'markdown', 'text', 'tex', 'rst' },
    callback = function()
      vim.opt_local.spell = true
      vim.opt_local.spelllang = 'en_us'
    end,
  },
})

-- Refresh mode highlights on mode change
augroup('mode_highlights', {
  {
    'ModeChanged',
    callback = function()
      local ok_modes, modes = pcall(require, 'modes')
      if ok_modes then
        modes.relink_highlights()
      else
        vim.notify('mode_highlights: modes plugin not found', vim.log.levels.WARN)
      end
    end,
  },
})

-- Attach LSP document highlighting for supported clients
augroup('document_highlight_attach', {
  {
    'LspAttach',
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client or not client:supports_method('textDocument/documentHighlight') or vim.fn.expand('%:p'):match('^fugitive://') then
        return
      end

      augroup('document_highlight_' .. bufnr, {
        {
          { 'CursorHold', 'CursorHoldI' },
          callback = function()
            vim.schedule(function()
              local clients = vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/documentHighlight' })
              if #clients > 0 then
                pcall(vim.lsp.buf.document_highlight)
              end
            end)
          end,
          buffer = bufnr,
        },
        {
          { 'CursorMoved', 'InsertEnter', 'BufLeave' },
          callback = function() pcall(vim.lsp.buf.clear_references) end,
          buffer = bufnr,
        },
        {
          'LspDetach',
          callback = function(detach_args)
            if detach_args.buf == bufnr then
              pcall(vim.lsp.buf.clear_references)
              pcall(vim.api.nvim_del_augroup_by_name, 'document_highlight_' .. bufnr)
            end
          end,
        },
      })
    end,
  },
})

-- Set LSP hover border on attach
augroup('lsp_hover_border', {
  {
    'LspAttach',
    callback = function(args)
      local bmap = utils.buffer_map(args.buf)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      -- Skip for filetypes where better-type-hover handles K
      local ft = vim.bo[args.buf].filetype
      if client and not vim.tbl_contains({ 'typescript', 'typescriptreact' }, ft) then
        bmap('n', 'K', function() vim.lsp.buf.hover({ border = 'rounded' }) end, { desc = 'LSP Hover Documentation' })
      end
      bmap('i', '<C-s>', function() vim.lsp.buf.signature_help({ border = 'rounded' }) end, { desc = 'Signature Help' })
    end,
  },
})

-- Cursorline only in focused window
augroup('cursorline_focus', {
  {
    'WinLeave',
    callback = function() vim.opt_local.cursorline = false end,
  },
  {
    'WinEnter',
    callback = function()
      if not vim.tbl_contains({ 'alpha', 'dashboard' }, vim.bo.filetype) then
        vim.opt_local.cursorline = true
      end
    end,
  },
})

-- Equalize split sizes after the terminal or UI is resized
augroup('equalize_splits_on_resize', {
  {
    'VimResized',
    callback = function() vim.cmd('wincmd =') end,
  },
})

-- Disable undo for temporary and commit files
augroup('disable_undo', {
  {
    'BufWritePre',
    pattern = { '/tmp/*', 'COMMIT_EDITMSG', 'MERGE_MSG', '*.tmp', '*.bak' },
    callback = function() vim.opt_local.undofile = false end,
  },
})

-- Toggle relative/absolute line numbers based on focus and mode
augroup('numbertoggle', {
  {
    { 'BufEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave', 'WinEnter' },
    pattern = '*',
    callback = function()
      if vim.o.number and not vim.tbl_contains({ 'help', 'terminal', 'nofile' }, vim.bo.buftype) then
        vim.opt.relativenumber = true
      end
    end,
  },
  {
    { 'BufLeave', 'FocusLost', 'InsertEnter', 'CmdlineEnter', 'WinLeave' },
    pattern = '*',
    callback = function()
      if vim.o.number then
        vim.opt.relativenumber = false
      end
    end,
  },
})

-- Auto-save when leaving Neovim focus, avoiding BufLeave-triggered formatter/watch churn.
if vim.g.auto_save_on_focus_lost == nil then
  vim.g.auto_save_on_focus_lost = true
end

local autosave_excluded = { 'oil', 'harpoon', 'alpha', 'dashboard', 'fugitive' }
local function auto_save_buffer(buf)
  if
    not vim.g.auto_save_on_focus_lost
    or not vim.api.nvim_buf_is_valid(buf)
    or not vim.bo[buf].modified
    or vim.bo[buf].buftype ~= ''
    or vim.api.nvim_buf_get_name(buf) == ''
    or vim.tbl_contains(autosave_excluded, vim.bo[buf].filetype)
  then
    return
  end

  local ok, err = pcall(vim.api.nvim_buf_call, buf, function() vim.api.nvim_cmd({ cmd = 'write', mods = { silent = true } }, {}) end)

  if ok then
    vim.notify('AutoSave: saved at ' .. vim.fn.strftime('%H:%M:%S'))
  else
    vim.notify('Auto-save failed: ' .. err, vim.log.levels.ERROR)
  end
end

augroup('auto_save', {
  {
    { 'FocusLost', 'VimLeavePre' },
    callback = function(args)
      local buf = args.buf ~= 0 and args.buf or vim.api.nvim_get_current_buf()
      auto_save_buffer(buf)
    end,
  },
})

vim.api.nvim_create_user_command('AutoSaveToggle', function()
  vim.g.auto_save_on_focus_lost = not vim.g.auto_save_on_focus_lost
  vim.notify('Auto-save ' .. (vim.g.auto_save_on_focus_lost and 'enabled' or 'disabled'))
end, { desc = 'Toggle auto-save on focus lost' })

-- Diff current buffer against the saved version on disk
vim.api.nvim_create_user_command('DiffSaved', function()
  local ft = vim.bo.filetype
  local saved = vim.fn.readfile(vim.fn.expand('%'))
  vim.cmd('diffthis')
  vim.cmd('vnew')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, saved)
  vim.cmd('diffthis')
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'wipe'
  vim.bo.swapfile = false
  vim.bo.filetype = ft
  vim.api.nvim_buf_set_name(0, '[Saved]')
end, { desc = 'Diff buffer against saved version on disk' })

-- Create jsconfig.json at the nearest project root
vim.api.nvim_create_user_command('JsConfig', function()
  local root = vim.fs.root(0, { 'package.json', '.git' })
  if not root then
    root = vim.fn.getcwd()
  end
  local path = root .. '/jsconfig.json'
  if vim.uv.fs_stat(path) then
    vim.notify('jsconfig.json already exists at ' .. path, vim.log.levels.WARN)
    return
  end
  local config = vim.fn.json_encode({
    compilerOptions = {
      checkJs = false,
      allowJs = true,
      noImplicitAny = false,
      moduleResolution = 'node',
      module = 'es2022',
      target = 'es2020',
    },
    exclude = { 'node_modules' },
  })
  vim.fn.writefile({ config }, path)
  vim.notify('Created ' .. path)
end, { desc = 'Create jsconfig.json at project root' })

-- Refresh Fugitive status after auto-save has flushed to disk
augroup('fugitive_refresh', {
  {
    'BufEnter',
    pattern = 'fugitive://*',
    callback = function()
      -- Only refresh in normal mode to avoid wiping visual selections
      -- and guard against re-entrant BufEnter from edit()
      if vim.fn.mode() ~= 'n' then
        return
      end
      if vim.b._fugitive_refreshing then
        return
      end
      vim.b._fugitive_refreshing = true
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(0) and vim.bo.filetype == 'fugitive' and vim.fn.mode() == 'n' then
          vim.cmd.edit()
        end
        vim.b._fugitive_refreshing = false
      end)
    end,
  },
})

-- Handle quitting Fugitive buffers gracefully
augroup('fugitive_quit', {
  {
    'BufHidden',
    pattern = 'fugitive://*',
    callback = function()
      vim.schedule(function()
        vim.cmd('silent! bdelete!')
        local bufnr = vim.api.nvim_get_current_buf()
        pcall(vim.lsp.buf.clear_references)
        pcall(vim.api.nvim_del_augroup_by_name, 'document_highlight_' .. bufnr)
      end)
    end,
  },
})
