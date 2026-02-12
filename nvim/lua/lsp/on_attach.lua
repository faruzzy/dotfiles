---Common LSP on_attach function
---Sets up buffer-local keymaps and settings for LSP
---@param client vim.lsp.Client
---@param bufnr number
return function(client, bufnr)
  local bsk = require('utils').buffer_map(bufnr)

  -- LSP actions (gd is handled by fzf-lua with jump-on-single-result)
  bsk('n', '<Leader>rn', vim.lsp.buf.rename, { desc = 'LSP Rename' })
  bsk('n', '<Leader>ca', vim.lsp.buf.code_action, { desc = 'LSP Code Action' })

  -- Inlay hints available but not auto-enabled due to Neovim 0.11.x
  -- rendering bug (Invalid 'col': out of range). Use <Leader>ti to toggle.
end
