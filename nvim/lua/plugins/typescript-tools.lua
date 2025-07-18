---@type LazySpec

return {
  'pmizio/typescript-tools.nvim',
  enabled = true,
  lazy = false,
  dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  config = function()
    require('typescript-tools').setup({
      capabilities = require('lsp.capabilities')(),
      settings = {
        complete_function_calls = false,
        include_completions_with_insert_text = true,
        -- Disable jsx_close_tag in favor of my own handling, default handling breaks emmet completion
        jsx_close_tag = { enable = false },
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
        local bsk = require('utils').buffer_map(bufnr)

        bsk('n', '<leader>oi', '<cmd>TSToolsOrganizeImports<CR>', { desc = 'Organize TypeScript imports' })
        bsk('n', '<leader>ia', '<cmd>TSToolsAddMissingImports<CR>', { desc = 'Add missing TypeScript imports' })
        bsk('n', '<leader>ri', '<cmd>TSToolsRemoveUnusedImports<CR>', { desc = 'Remove unused TypeScript imports' })

        if
          vim.tbl_contains({
            'javascript',
            'javascriptreact',
            'typescriptreact',
          }, vim.bo.filetype)
        then
          bsk('i', '>', function()
            local success, result = pcall(function()
              require('typescript-tools.api').jsx_close_tag(
                bufnr,
                vim.lsp.util.make_position_params(0, client.offset_encoding or 'utf-16'),
                vim.schedule,
                nil
              )
            end)
            if not success and debug then
              print('jsx_close_tag failed: ' .. tostring(result))
            end
            return '>'
          end, { expr = true, desc = 'Auto-close JSX/TSX tags' })
        end
      end,
    })
  end,
}
