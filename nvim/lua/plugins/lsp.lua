--[[
  LSP configuration using Neovim's native vim.lsp API (0.11+).
  - Mason handles server installation.
  - vim.lsp.config/enable replaces nvim-lspconfig.
  - Shared on_attach logic via LspAttach autocmd.
]]

return {
  'williamboman/mason.nvim',
  dependencies = {
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- JSON schemas for better completion
    'b0o/schemastore.nvim',

    -- Useful status updates for LSP
    {
      'j-hui/fidget.nvim',
      opts = {
        notification = {
          window = {
            winblend = 0,
            align = 'bottom',
          },
        },
        progress = {
          display = {
            render_limit = 5,
          },
        },
      },
    },
  },

  config = function()
    require('mason').setup()

    -- Mason package names for installation
    require('mason-tool-installer').setup({
      ensure_installed = {
        -- LSP servers
        'clangd',
        'css-lsp',
        'emmet-language-server',
        'eslint-lsp',
        'html-lsp',
        'json-lsp',
        'lua-language-server',
        'pyright',
        'rust-analyzer',
        'tailwindcss-language-server',
        'vim-language-server',
        'yaml-language-server',
        -- Formatters
        'stylua',
        'prettierd',
      },
      auto_update = false,
    })

    -- Shared capabilities for all servers
    vim.lsp.config('*', {
      capabilities = require('lsp.capabilities')(),
    })

    -- Per-server configuration
    local servers = require('lsp.servers')
    for name, config in pairs(servers) do
      if not vim.tbl_isempty(config) then
        vim.lsp.config(name, config)
      end
    end

    -- Enable servers (rust_analyzer managed by rustaceanvim)
    local skip = { 'rust_analyzer' }
    local to_enable = vim.tbl_filter(function(name) return not vim.tbl_contains(skip, name) end, vim.tbl_keys(servers))
    vim.lsp.enable(to_enable)

    local function sanitize_watched_file_registrations(result)
      for _, reg in ipairs(result and result.registrations or {}) do
        if reg.method == 'workspace/didChangeWatchedFiles' and reg.registerOptions then
          reg.registerOptions.watchers = vim.tbl_filter(function(watcher)
            local glob_pattern = watcher.globPattern
            return not (type(glob_pattern) == 'string' and glob_pattern:match('^bundled:///'))
          end, reg.registerOptions.watchers or {})
        end
      end
    end

    local register_capability = vim.lsp.handlers['client/registerCapability']
    vim.lsp.handlers['client/registerCapability'] = function(err, result, ctx, config)
      sanitize_watched_file_registrations(result)

      local ret = register_capability(err, result, ctx, config)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      if client then
        for bufnr in pairs(client.attached_buffers) do
          if vim.api.nvim_buf_is_valid(bufnr) and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, bufnr) then
            pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
          end
        end
      end
      return ret
    end

    -- Shared on_attach for all LSP servers
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('shared_lsp_on_attach', { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
          return
        end
        require('lsp.on_attach')(client, args.buf)
      end,
    })
  end,
}
