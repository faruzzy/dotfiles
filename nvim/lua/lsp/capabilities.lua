return function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  local ok_file_operations, file_operations = pcall(require, 'lsp-file-operations')
  if ok_file_operations then
    capabilities = vim.tbl_deep_extend('force', capabilities, file_operations.default_capabilities())
  end

  return capabilities
end
