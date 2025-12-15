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
            winblend = 0,     -- Opaque background
            align = 'bottom', -- Align notifications at the bottom
          },
        },
        progress = {
          display = {
            render_limit = 5, -- Limit number of progress messages shown
          },
        },
      },
    },
  },

  config = function()
    require('mason').setup()
    local servers = require('lsp.servers')

    -- Separate formatters from LSP servers
    local formatters = { 'stylua', 'prettierd' }

    require('mason-tool-installer').setup({
      ensure_installed = vim.list_extend(vim.tbl_keys(servers), formatters),
      auto_update = false, -- Prevent automatic updates for reproducibility
    })

    require('mason-lspconfig').setup({
      ensure_installed = vim.tbl_keys(servers),
      handlers = {
        function(server_name)
          local capabilities = require('lsp.capabilities')()
          local server = servers[server_name] or {}

          local config = { capabilities = capabilities }

          -- Call the config function if it exists
          if server.config and type(server.config) == 'function' then
            config = server.config(config)
          end

          require('lspconfig')[server_name].setup(config)
        end,
      },
    })
  end,
}
