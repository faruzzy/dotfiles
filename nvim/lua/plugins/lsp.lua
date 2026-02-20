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

    -- JSON schemas for better completion
    'b0o/schemastore.nvim',

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
          -- Only setup servers explicitly listed in lsp/servers.lua
          local server = servers[server_name]
          if not server or server_name == 'jsonls' or server_name == 'rust_analyzer' then
            return
          end

          local capabilities = require('lsp.capabilities')()
          local on_attach = require('lsp.on_attach')

          local config = {
            capabilities = capabilities,
            on_attach = on_attach,
          }

          -- Call the config function if it exists
          if server.config and type(server.config) == 'function' then
            config = server.config(config)
          end

          require('lspconfig')[server_name].setup(config)
        end,
      },
    })

    -- Apply lua_ls settings via vim.lsp.config so they merge with lazydev
    local lua_ls_server = servers['lua_ls']
    if lua_ls_server and lua_ls_server.config then
      local lua_ls_config = lua_ls_server.config({
        capabilities = require('lsp.capabilities')(),
        on_attach = require('lsp.on_attach'),
      })
      vim.lsp.config('lua_ls', {
        settings = lua_ls_config.settings,
      })
    end

    -- Manually setup jsonls (handlers don't run for already-installed servers)
    local capabilities = require('lsp.capabilities')()
    local on_attach = require('lsp.on_attach')
    local ok, schemastore = pcall(require, 'schemastore')

    vim.lsp.config('jsonls', {
      cmd = { 'vscode-json-language-server', '--stdio' },
      filetypes = { 'json', 'jsonc' },
      root_markers = { '.git' },
      single_file_support = true,
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        json = {
          schemas = ok and schemastore.json.schemas() or {
            -- Fallback schemas if schemastore not available
            {
              fileMatch = { 'package.json' },
              url = 'https://json.schemastore.org/package.json',
            },
            {
              fileMatch = { 'tsconfig*.json' },
              url = 'https://json.schemastore.org/tsconfig.json',
            },
            {
              fileMatch = { 'jsconfig*.json' },
              url = 'https://json.schemastore.org/jsconfig.json',
            },
          },
          validate = { enable = true },
          format = { enable = true },
        },
      },
    })

    -- Enable jsonls for json/jsonc files
    vim.lsp.enable('jsonls')
  end,
}
