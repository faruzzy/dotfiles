-- vtsls: VS Code's TypeScript language server for Neovim
-- Replaces typescript-tools.nvim with better VS Code feature parity

local ts_filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' }

return {
  'yioneko/nvim-vtsls',
  ft = ts_filetypes,
  dependencies = { 'neovim/nvim-lspconfig' },
  config = function()
    require('lspconfig.configs').vtsls = require('vtsls').lspconfig

    local server_config = require('lsp.servers.vtsls')
    local config = {
      capabilities = require('lsp.capabilities')(),
    }
    if server_config.config then config = server_config.config(config) end
    require('lspconfig').vtsls.setup(config)

    local commands = require('vtsls').commands

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('vtsls_attach', { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or client.name ~= 'vtsls' then return end

        -- Run shared on_attach (inlay hints, lightbulb, keymaps)
        require('lsp.on_attach')(client, args.buf)

        -- Disable formatting (conform.nvim handles it)
        client.server_capabilities.documentFormattingProvider = false

        local bufnr = args.buf
        local bsk = require('utils').buffer_map(bufnr)

        -- Same mappings as previous typescript-tools config
        bsk(
          'n',
          '<leader>io',
          function() commands.organize_imports(bufnr) end,
          { desc = 'Organize TypeScript imports' }
        )
        bsk(
          'n',
          '<leader>ia',
          function() commands.add_missing_imports(bufnr) end,
          { desc = 'Add missing TypeScript imports' }
        )
        bsk(
          'n',
          '<leader>ir',
          function() commands.remove_unused_imports(bufnr) end,
          { desc = 'Remove unused TypeScript imports' }
        )
        bsk('n', '<leader>if', function() commands.fix_all(bufnr) end, { desc = 'Fix all TypeScript diagnostics' })

        -- New vtsls-only features
        bsk('n', 'gD', function() commands.goto_source_definition(bufnr) end, { desc = 'Goto Source Definition' })
        bsk('n', 'gR', function() commands.file_references(bufnr) end, { desc = 'File References' })
      end,
    })
  end,
}
