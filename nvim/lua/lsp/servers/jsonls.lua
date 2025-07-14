---@type LspServer
return {
  -- Configuration for JSON Language Server (jsonls)
  -- Provides schema validation and diagnostics for JSON files
  -- Depends on: mason-lspconfig, cmp.nvim, catppuccin.nvim
  config = function(config)
    config.settings = {
      json = {
        -- https://www.schemastore.org
        schemas = {
          {
            fileMatch = { '.babelrc', '.babelrc.json', 'babel.config.json' },
            url = 'https://json.schemastore.org/babelrc.json',
          },
          {
            fileMatch = { '.eslintrc', '.eslintrc.json' },
            url = 'https://json.schemastore.org/eslintrc.json',
          },
          {
            fileMatch = { 'package.json' },
            url = 'https://json.schemastore.org/package.json',
          },
          {
            fileMatch = { 'jsconfig*.json' },
            url = 'https://json.schemastore.org/jsconfig.json',
          },
          {
            fileMatch = { 'tsconfig*.json' },
            url = 'https://json.schemastore.org/tsconfig.json',
          },
        },
        format = {
          enable = true,
        },
        validate = { enable = true },
        jsonFormatter = {
          tabSize = 2,
          insertSpaces = true,
        },
        suggest = {
          showWords = true,
          completeFunctionCalls = true,
        },
        diagnostic = {
          enable = true,
          severity = 'warning',
          virtual_text = true,
        },
      },
    }

    return config
  end,
  install = { 'npm', 'install', '-g', 'vscode-langservers-extracted@4.8.0' }, -- Pin version
  fallback = { 'yarn', 'global', 'add', 'vscode-langservers-extracted' },     -- Fallback
}
