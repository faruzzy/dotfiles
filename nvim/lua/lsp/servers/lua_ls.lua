---@type LspServer
return {
  -- Configuration for Lua Language Server (lua_ls)
  -- Provides LSP support for Lua files, including Neovim config
  -- Depends on: mason-lspconfig, cmp.nvim, catppuccin.nvim, autocmd.lua
  config = function(config)
    config.settings = {
      Lua = {
        completion = {
          keywordSnippet = 'Disable', -- Avoid snippet conflicts with cmp.lua
          callSnippet = 'Disable',
          autoRequire = true,         -- Auto-import Lua modules
        },
        hint = {
          arrayIndex = 'Disable',
          enable = true,
          setType = true,    -- Show type hints
          paramName = 'All', -- Show parameter names
          paramType = true,  -- Show parameter types
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.fn.expand('$VIMRUNTIME/lua'),
            vim.fn.stdpath('config') .. '/lua',
          },
          maxPreload = 1000, -- Increase preload limit
        },
        runtime = {
          version = 'LuaJIT',
          path = vim.split(package.path, ';'),
        },
        telemetry = { enable = false },
        diagnostics = {
          disable = { 'missing-fields' },
          globals = { 'vim', 'require', 'pcall', 'describe', 'it' }, -- Common globals
          severity = {
            ['undefined-global'] = 'Warning',                        -- Downgrade from error
          },
        },
        format = {
          enable = true,
          defaultConfig = {
            indent_style = 'space',
            indent_size = 2,
          },
        },
      },
    }
    -- Request inlay hint capability (merge with existing capabilities)
    config.capabilities.textDocument.inlayHint = { dynamicRegistration = true }
    return config
  end,
  install = { 'brew', 'install', 'lua-language-server@3.9.0' },       -- Pin version
  fallback = { 'npm', 'install', '-g', 'lua-language-server@3.9.0' }, -- Fallback
}
