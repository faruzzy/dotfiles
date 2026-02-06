---@type LazySpec

return {
  'pmizio/typescript-tools.nvim',
  ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  config = function()
    require('typescript-tools').setup({
      capabilities = (function()
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        local ok, blink = pcall(require, 'blink.cmp')
        if ok then
          capabilities = blink.get_lsp_capabilities(capabilities)
        end
        return capabilities
      end)(),
      settings = {
        separate_diagnostic_server = false,
        publish_diagnostic_on = 'insert_leave',
        complete_function_calls = false,
        include_completions_with_insert_text = true,
        jsx_close_tag = { enable = true },
        expose_as_code_action = {
          'fix_all',
          'add_missing_imports',
          'remove_unused',
          'organize_imports',
        },
        tsserver_file_preferences = {
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = false,
          includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        },
        tsserver_plugins = { 'typescript-svelte-plugin' },
      },
      handlers = {
        ['textDocument/publishDiagnostics'] = require('typescript-tools.api').filter_diagnostics({
          80001, -- File is a CommonJS module; it may be converted to an ES module.
        }),
      },
      on_attach = function(client, bufnr)
        -- Enable inlay hints if supported
        if client.server_capabilities.inlayHintProvider then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end

        local bsk = require('utils').buffer_map(bufnr)

        bsk('n', '<leader>io', '<cmd>TSToolsOrganizeImports<CR>', { desc = 'Organize TypeScript imports' })
        bsk('n', '<leader>ia', '<cmd>TSToolsAddMissingImports<CR>', { desc = 'Add missing TypeScript imports' })
        bsk('n', '<leader>ir', '<cmd>TSToolsRemoveUnusedImports<CR>', { desc = 'Remove unused TypeScript imports' })

        local is_jsx_file =
            vim.tbl_contains({ 'javascript', 'javascriptreact', 'typescriptreact' }, vim.bo[bufnr].filetype)

        if is_jsx_file then
          bsk('i', '>', function()
            pcall(function()
              require('typescript-tools.api').jsx_close_tag(
                bufnr,
                vim.lsp.util.make_position_params(0, client.offset_encoding or 'utf-16'),
                vim.schedule,
                nil
              )
            end)
            return '>'
          end, { expr = true, desc = 'Auto-close JSX/TSX tags' })
        end
      end,
    })
  end,
}
