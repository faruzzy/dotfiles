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
          require('lsp.on_attach')(client, bufnr)
          -- Disable Neovim's built-in inlay hints for Rust to avoid
          -- 'Invalid col: out of range' errors (Neovim 0.11.x bug)
          vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
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
