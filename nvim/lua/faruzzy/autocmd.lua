local utils = require('utils')
local augroup = utils.augroup

-- Prevent auto-commenting on Enter or o/O
augroup('no_auto_comment', {
  {
    'FileType',
    command = 'setlocal formatoptions-=r formatoptions-=o',
  },
})

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
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local before = line:sub(1, col)
        local after = line:sub(col + 1)

        -- /**| + Enter → expand block. `after` may be '' or '*/' (autopairs).
        if before:match('^%s*/%*%*$') and (after == '' or after:match('^%s*%*/%s*$')) then
          local indent = before:match('^(%s*)')
          vim.schedule(function()
            vim.api.nvim_buf_set_lines(0, row - 1, row, false, {
              before,
              indent .. ' * ',
              indent .. ' */',
            })
            vim.api.nvim_win_set_cursor(0, { row + 1, #indent + 3 })
          end)
          return ''
        end

        -- Inside block, continue with aligned " * ". Skip the closing " */"
        -- line so Enter there falls through to a plain newline.
        if before:match('^%s*%*') and not before:match('^%s*%*/') then
          local indent = before:match('^(%s*)')
          local prefix = indent .. '* '
          vim.schedule(function()
            vim.api.nvim_buf_set_lines(0, row - 1, row, false, {
              before,
              prefix .. after,
            })
            vim.api.nvim_win_set_cursor(0, { row + 1, #prefix })
          end)
          return ''
        end

        return require('nvim-autopairs').autopairs_cr()
      end, { expr = true, replace_keycodes = false })

      -- Same fix for 'o' in normal mode: bypass smartindent inside block comments
      bmap('n', 'o', function()
        local line = vim.api.nvim_get_current_line()
        if line:match('^%s*%*') and not line:match('^%s*%*/') then
          local indent = line:match('^(%s*)')
          return 'o<C-u>' .. indent .. '* '
        end

        return 'o'
      end, { expr = true, replace_keycodes = true })
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

      local timer = assert(vim.uv.new_timer())

      augroup('document_highlight_' .. bufnr, {
        {
          { 'CursorHold', 'CursorHoldI', 'CursorMoved', 'CursorMovedI' },
          callback = function()
            timer:stop()
            pcall(vim.lsp.buf.clear_references)
            timer:start(
              200,
              0,
              vim.schedule_wrap(function()
                if not vim.api.nvim_buf_is_valid(bufnr) or vim.fn.mode() ~= 'n' then
                  return
                end
                local clients = vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/documentHighlight' })
                if #clients > 0 then
                  pcall(vim.lsp.buf.document_highlight)
                end
              end)
            )
          end,
          buffer = bufnr,
        },
        {
          { 'InsertEnter', 'BufLeave' },
          callback = function()
            timer:stop()
            pcall(vim.lsp.buf.clear_references)
          end,
          buffer = bufnr,
        },
        {
          'LspDetach',
          callback = function(detach_args)
            if detach_args.buf == bufnr then
              timer:stop()
              if not timer:is_closing() then
                timer:close()
              end
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

-- Wipe hidden Fugitive buffers so they don't accumulate in the buffer list
augroup('fugitive_quit', {
  {
    'BufHidden',
    pattern = 'fugitive://*',
    callback = function(args)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(args.buf) then
          pcall(vim.api.nvim_buf_delete, args.buf, { force = true })
        end
      end)
    end,
  },
})
