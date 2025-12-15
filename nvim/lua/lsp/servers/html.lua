---@type LspServer
return {
  config = function(config)
    config.on_attach = function(client, bufnr)
      require('lsp.utils').setup_auto_close_tag(client, bufnr, 'html/autoInsert')
    end

    return config
  end,
}
