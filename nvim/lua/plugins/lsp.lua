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
      'stylua',    -- Lua formatter
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
          local capabilities = vim.lsp.protocol.make_client_capabilities()

          local ok, blink = pcall(require, 'blink.cmp')
          if ok then
            capabilities = blink.get_lsp_capabilities(capabilities)
          end

          local server = servers[server_name] or {}

          local config = {
            capabilities = capabilities,
          }

          -- Call the config function if it exists
          if server.config and type(server.config) == 'function' then
            config = server.config(config)
          end

          require('lspconfig')[server_name].setup(config)
        end,
      },
    })

    -- Explicitly setup servers with custom configs (in case handlers didn't fire)
    for server_name, server_config in pairs(servers) do
      if server_config.config and type(server_config.config) == 'function' then
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        local ok, blink = pcall(require, 'blink.cmp')
        if ok then
          capabilities = blink.get_lsp_capabilities(capabilities)
        end

        local config = { capabilities = capabilities }
        config = server_config.config(config)

        -- Force re-setup with correct config
        require('lspconfig')[server_name].setup(config)
      end
    end
  end,
}
