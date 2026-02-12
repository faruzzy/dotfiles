---Common LSP on_attach function
---Sets up buffer-local keymaps and settings for LSP
---@param client vim.lsp.Client
---@param bufnr number
return function(client, bufnr)
  local bsk = require('utils').buffer_map(bufnr)

  -- LSP actions (gd is handled by fzf-lua with jump-on-single-result)
  bsk('n', '<Leader>rn', vim.lsp.buf.rename, { desc = 'LSP Rename' })
  bsk('n', '<Leader>ca', vim.lsp.buf.code_action, { desc = 'LSP Code Action' })

  -- Enable inlay hints if supported
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end
