--[[
  LSP configuration for Neovim using nvim-lspconfig and mason.nvim.
  - Sets up LSP servers with custom keybindings and formatting.
  - Manages server installation via mason.nvim.
  - Provides status updates via fidget.nvim.
  - See lsp/servers.lua for server-specific settings.
]]

return {
  -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs to stdpath for neovim
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Useful status updates for LSP
    {
      'j-hui/fidget.nvim',
      opts = {
        notification = {
          window = {
            winblend = 0, -- Opaque background
            align = 'bottom', -- Align notifications at the bottom
          },
          progress = {
            display = {
              render_limit = 5, -- Limit number of progress messages shown
            },
          },
        },
      },
      tag = 'legacy',
    },
  },

  config = function()
    require('mason').setup()
    local servers = require('lsp.servers')
    local lsp_servers = vim.tbl_keys(servers or {})

    vim.list_extend(lsp_servers, {
      'stylua', -- Lua formatter
      'prettierd', -- JavaScript/TypeScript formatter
    })

    require('mason-tool-installer').setup({
      ensure_installed = lsp_servers,
      auto_update = false, -- Prevent automatic updates for reproducibility
    })

    require('mason-lspconfig').setup({
      ensure_installed = vim.tbl_keys(servers),
      handlers = {
        function(server_name)
          local capabilities = require('cmp_nvim_lsp').default_capabilities()
          local server = servers[server_name] or {}

          require('lspconfig')[server_name].setup(vim.tbl_deep_extend('force', {
            capabilities = capabilities,
          }, server))
        end,
      },
    })
  end,
}
