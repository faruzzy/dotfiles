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
          local map = require('utils').buffer_map(bufnr)
          map('n', 'gK', '<cmd>RustLsp externalDocs<cr>', { desc = 'Open docs.rs' })
          map('n', 'gBa', '<cmd>RustLsp hover actions<cr>', { desc = 'Hover actions' })
          map('n', 'gBr', '<cmd>RustLsp runnables<cr>', { desc = 'Run targets' })
          map('n', 'gBR', '<cmd>RustLsp debuggables<cr>', { desc = 'Debug targets' })
          map('n', 'gBe', '<cmd>RustLsp expandMacro<cr>', { desc = 'Expand macro' })
          map('n', 'gBE', '<cmd>RustLsp explainError<cr>', { desc = 'Explain error' })
          map('n', 'gBd', '<cmd>RustLsp renderDiagnostic<cr>', { desc = 'Render diagnostic' })
          map('n', 'gBm', '<cmd>RustLsp parentModule<cr>', { desc = 'Parent module' })
          map('n', 'gBc', '<cmd>RustLsp openCargo<cr>', { desc = 'Open Cargo.toml' })
          map('n', 'gBp', '<cmd>RustLsp rebuildProcMacros<cr>', { desc = 'Rebuild proc macros' })
          map('n', 'gBw', '<cmd>RustLsp reloadWorkspace<cr>', { desc = 'Reload workspace' })
          map('n', 'gBu', '<cmd>RustLsp moveItem up<cr>', { desc = 'Move item up' })
          map('n', 'gBD', '<cmd>RustLsp moveItem down<cr>', { desc = 'Move item down' })
        end,
        settings = {
          ['rust-analyzer'] = {
            checkOnSave = {
              command = 'clippy',
              extraArgs = { '--no-deps' },
            },
            lens = {
              enable = true,
              references = true,
              implementations = true,
              enumVariantReferences = true,
              methodReferences = true,
            },
            cargo = {
              allFeatures = true,
              buildScripts = { enable = true },
            },
            procMacro = { enable = true },
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
