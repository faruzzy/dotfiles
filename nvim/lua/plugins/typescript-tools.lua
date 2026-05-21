-- vtsls: VS Code's TypeScript language server for Neovim
-- Uses native vim.lsp API + nvim-vtsls for TS-specific commands

local ts_filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' }

return {
  'yioneko/nvim-vtsls',
  ft = ts_filetypes,
  config = function()
    -- Enable vtsls via native API (config comes from lsp/servers/vtsls.lua)
    vim.lsp.enable('vtsls')

    local commands = require('vtsls').commands

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('vtsls_attach', { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or client.name ~= 'vtsls' then
          return
        end

        -- Disable formatting (conform.nvim handles it)
        client.server_capabilities.documentFormattingProvider = false

        local bufnr = args.buf
        local bsk = require('utils').buffer_map(bufnr)

        bsk('n', '<leader>io', function() commands.organize_imports(bufnr) end, { desc = 'Organize TypeScript imports' })
        bsk('n', '<leader>ia', function() commands.add_missing_imports(bufnr) end, { desc = 'Add missing TypeScript imports' })
        bsk('n', '<leader>ir', function() commands.remove_unused_imports(bufnr) end, { desc = 'Remove unused TypeScript imports' })
        bsk('n', '<leader>if', function() commands.fix_all(bufnr) end, { desc = 'Fix all TypeScript diagnostics' })

        bsk('n', 'gD', function() commands.goto_source_definition(bufnr) end, { desc = 'Goto Source Definition' })
        bsk('n', 'gR', function() require('lsp.enclosing_references').find() end, { desc = 'Find references to enclosing function' })
      end,
    })
  end,
}
