return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml' },
  settings = {
    Lua = {
      completion = {
        keywordSnippet = 'Disable',
        callSnippet = 'Disable',
        autoRequire = true,
      },
      hint = {
        arrayIndex = 'Disable',
        enable = true,
        setType = false,
        paramName = 'All',
        paramType = false,
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.fn.expand('$VIMRUNTIME/lua'),
          vim.fn.stdpath('config') .. '/lua',
        },
        maxPreload = 1000,
      },
      runtime = {
        version = 'LuaJIT',
        path = vim.split(package.path, ';'),
      },
      telemetry = { enable = false },
      diagnostics = {
        disable = { 'missing-fields' },
        globals = { 'vim', 'require', 'pcall', 'describe', 'it' },
        severity = {
          ['undefined-global'] = 'Warning',
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
  },
}
