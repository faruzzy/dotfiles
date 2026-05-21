local ok, schemastore = pcall(require, 'schemastore')

return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  single_file_support = true,
  settings = {
    json = {
      schemas = ok and schemastore.json.schemas() or {
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
}
