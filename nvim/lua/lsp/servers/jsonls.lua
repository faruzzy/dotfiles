---@type LspServer
return {
  config = function(config)
    local ok, schemastore = pcall(require, 'schemastore')

    config.cmd = { 'vscode-json-language-server', '--stdio' }
    config.filetypes = { 'json', 'jsonc' }
    config.single_file_support = true
    config.settings = {
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
    }
    return config
  end,
}
