---@type LspServer
return {
  config = function(config)
    config.settings = {
      Lua = {
        completion = { keywordSnippet = 'Replace', callSnippet = 'Replace' },
        hint = { arrayIndex = 'Disable', enable = true },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
        diagnostics = {
          disable = { 'missing-fields' },
          globals = { 'vim' },
        },
      },
    }

    return config
  end,
  install = { 'brew', 'lua-language-server' },
}
