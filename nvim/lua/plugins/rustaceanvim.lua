return {
  'mrcjkb/rustaceanvim',
  version = '^5',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'mfussenegger/nvim-dap',
  },
  ft = { 'rust' },
  config = function()
    vim.g.rustaceanvim = {
      tools = {
        hover_actions = {
          auto_focus = true,
        },
        -- Disable rustaceanvim's inlay hints
        inlay_hints = {
          auto = true, -- This disables rustaceanvim's hints
        },
      },
      server = {
        on_attach = function(client, bufnr)
          -- Only use Neovim's built-in inlay hints
          if vim.lsp.inlay_hint and client.supports_method('textDocument/inlayHint') then
            vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
          end

          local opts = { buffer = bufnr }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        end,
        settings = {
          ['rust-analyzer'] = {
            checkOnSave = true,
            -- Configure rust-analyzer's inlay hints (these feed into Neovim's built-in system)
            inlayHints = {
              parameterHints = {
                enable = true,
              },
              typeHints = {
                enable = true,
              },
              chainingHints = {
                enable = true,
              },
            },
          },
        },
      },
    }
  end,
}
