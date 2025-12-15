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
          {
            fileMatch = { '.prettierrc', '.prettierrc.json', 'prettier.config.json' },
            url = 'https://json.schemastore.org/prettierrc.json',
          },
          {
            fileMatch = { '.eslintrc', '.eslintrc.json' },
            url = 'https://json.schemastore.org/eslintrc.json',
          },
          {
            fileMatch = { '.babelrc', '.babelrc.json', 'babel.config.json' },
            url = 'https://json.schemastore.org/babelrc.json',
          },
          {
            fileMatch = { 'lerna.json' },
            url = 'https://json.schemastore.org/lerna.json',
          },
          {
            fileMatch = { 'now.json', 'vercel.json' },
            url = 'https://json.schemastore.org/now.json',
          },
          {
            fileMatch = { '.stylelintrc', '.stylelintrc.json', 'stylelint.config.json' },
            url = 'https://json.schemastore.org/stylelintrc.json',
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
}
