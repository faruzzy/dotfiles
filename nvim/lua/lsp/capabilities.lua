return function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  return capabilities
end
