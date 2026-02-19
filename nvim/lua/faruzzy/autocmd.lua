local augroup = require('utils').augroup

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
    callback = function()
      vim.opt_local.formatoptions:append('ro')
      vim.opt_local.comments = 'sO:* -,mO:*  ,exO:*/,s1:/*,mb:*,ex:*/,://'

      -- JSDoc auto-expansion on Enter after /**
      vim.keymap.set('i', '<CR>', function()
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

        -- Otherwise use autopairs CR
        return require('nvim-autopairs').autopairs_cr()
      end, { buffer = true, expr = true, replace_keycodes = false })
    end,
  },
})

-- Highlight yanked text briefly
augroup('YankHighlight', {
  {
    'TextYankPost',
    callback = function()
      if vim.bo.buftype == '' then
        vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
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

-- Refresh mode highlights and tint on mode change
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
      local ok_tint, tint = pcall(require, 'tint')
      if ok_tint then
        tint.refresh()
      else
        vim.notify('mode_highlights: tint plugin not found', vim.log.levels.WARN)
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
      if
        not client
        or not client.supports_method('textDocument/documentHighlight')
        or vim.fn.expand('%:p'):match('^fugitive://')
      then
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
          callback = function()
            pcall(vim.lsp.buf.clear_references)
          end,
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
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      -- Skip for filetypes where better-type-hover handles K
      local ft = vim.bo[args.buf].filetype
      if client and not vim.tbl_contains({ 'typescript', 'typescriptreact' }, ft) then
        vim.keymap.set('n', 'K', function()
          vim.lsp.buf.hover({ border = 'rounded' })
        end, { buffer = args.buf, desc = 'LSP Hover Documentation' })
      end
    end,
  },
})

-- Cursorline only in focused window
augroup('cursorline_focus', {
  {
    'WinLeave',
    callback = function()
      vim.opt_local.cursorline = false
    end,
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

-- Disable undo for temporary and commit files
augroup('disable_undo', {
  {
    'BufWritePre',
    pattern = { '/tmp/*', 'COMMIT_EDITMSG', 'MERGE_MSG', '*.tmp', '*.bak' },
    callback = function()
      vim.opt_local.undofile = false
    end,
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
