local augroup = require('utils').augroup

-- [[ Prevent auto comment on <CR> ]]
local no_auto_comment = vim.api.nvim_create_augroup('no_auto_comment', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  command = 'setlocal formatoptions-=r formatoptions-=o',
  group = no_auto_comment,
})

-- [[ Highlight on yank ]]
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

local spell_group = vim.api.nvim_create_augroup('spell_group', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'gitcommit,markdown',
  command = 'setlocal spell',
  group = spell_group,
})

augroup('mode_highlights', {
  {
    'ModeChanged',
    callback = function()
      require('modes').relink_highlights()
      require('tint').refresh()
    end,
  },
})

augroup('document_highlight_attach', {
  {
    'LspAttach',
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      if not client or not client.supports_method('textDocument/documentHighlight') then
        return
      end

      augroup('document_highlight', {
        {
          { 'CursorHold', 'CursorHoldI' },
          callback = vim.lsp.buf.document_highlight,
          buffer = bufnr,
        },
        {
          { 'CursorMoved', 'InsertEnter', 'BufLeave' },
          callback = vim.lsp.buf.clear_references,
          buffer = bufnr,
        },
        {
          { 'LspDetach' },
          callback = vim.lsp.buf.clear_references,
        },
      })
    end,
  },
})

local numbertoggle = vim.api.nvim_create_augroup('numbertoggle', { clear = true })

-- Toggle between relative/absolute line numbers
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave', 'WinEnter' }, {
  pattern = '*',
  group = numbertoggle,
  callback = function()
    if vim.o.nu and vim.api.nvim_get_mode().mode ~= 'i' then
      vim.opt.relativenumber = true
    end
  end,
})

vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'CmdlineEnter', 'WinLeave' }, {
  pattern = '*',
  group = numbertoggle,
  callback = function()
    if vim.o.nu then
      vim.opt.relativenumber = false
      vim.cmd.redraw()
    end
  end,
})
