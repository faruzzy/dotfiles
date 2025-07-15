local augroup = require('utils').augroup

-- Prevent auto-commenting on Enter or o/O
augroup('no_auto_comment', {
  {
    'FileType',
    command = 'setlocal formatoptions-=r formatoptions-=o',
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
              pcall(vim.lsp.buf.document_highlight, bufnr)
            end)
          end,
          buffer = bufnr,
        },
        {
          { 'CursorMoved', 'InsertEnter', 'BufLeave' },
          callback = function()
            pcall(vim.lsp.buf.clear_references, bufnr)
          end,
          buffer = bufnr,
        },
        {
          'LspDetach',
          callback = function(detach_args)
            if detach_args.buf == bufnr then
              pcall(vim.lsp.buf.clear_references, bufnr)
              pcall(vim.api.nvim_del_augroup_by_name, 'document_highlight_' .. bufnr)
            end
          end,
        },
      })
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

-- Auto-format LSP-supported files on save
augroup('lsp_format', {
  {
    'BufWritePre',
    pattern = { '*.js', '*.ts', '*.jsx', '*.tsx', '*.lua', '*.py' },
    callback = function(args)
      if
        vim.g.disable_autoformat
        or not vim.bo.modifiable
        or vim.bo.buftype ~= ''
        or vim.fn.expand('%:p'):match('^fugitive://')
      then
        return
      end
      local bufnr = args.buf
      local client = vim.lsp.get_active_clients({ bufnr = bufnr })[1]
      if client and client.supports_method('textDocument/formatting') then
        vim.lsp.buf.format({ bufnr = bufnr, async = false })
      elseif vim.bo.filetype == 'javascript' or vim.bo.filetype == 'typescript' then
        if vim.fn.exists(':EslintFixAll') == 1 then
          vim.cmd.EslintFixAll()
        end
      end
    end,
  },
})

-- Handle quitting Fugitive buffers gracefully
augroup('fugitive_quit', {
  {
    'BufWinLeave',
    pattern = 'fugitive://*',
    callback = function()
      vim.cmd('silent! bdelete!')
      local bufnr = vim.api.nvim_get_current_buf()
      pcall(vim.lsp.buf.clear_references, bufnr)
      pcall(vim.api.nvim_del_augroup_by_name, 'document_highlight_' .. bufnr)
    end,
  },
})
