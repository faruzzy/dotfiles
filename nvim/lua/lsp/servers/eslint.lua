--[[
  ESLint LSP configuration for Neovim.
  - Sets up root directory detection for ESLint projects.
  - Adds a keybinding for EslintFixAll.
  - Customizes diagnostic severity to align with Neovim's LSP.
  - Specifies installation via npm.
]]

---@type LspServer
return {
  config = function(config)
    config.root_dir = require('lspconfig').util.root_pattern(
      '.eslintrc',
      '.eslintrc.js',
      '.eslintrc.cjs',
      '.eslintrc.yaml',
      '.eslintrc.yml',
      '.eslintrc.json',
      'eslint.config.js',
      'eslint.config.mjs',
      'eslint.config.cjs',
      'package.json',
      './node_modules/eslint'
    ) or vim.fn.getcwd()

    config.on_attach = function(client, bufnr)
      if vim.fn.exists(':EslintFixAll') == 1 then
        require('utils').buffer_map(bufnr)('n', '<leader>ef', vim.cmd.EslintFixAll)
      end
      if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
    end

    config.handlers = {
      -- Suppress "Unable to find ESLint library" warning
      ['window/showMessageRequest'] = function(_, result)
        if result and result.message and result.message:find('Unable to find ESLint library') then
          return vim.NIL
        end
        return vim.lsp.handlers['window/showMessageRequest'](_, result)
      end,
      ['textDocument/diagnostic'] = function(err, result, ctx)
        if result and result.items then
          for _, item in ipairs(result.items) do
            item.severity = item.severity == 1 and 1 or item.severity == 2 and 2 or 4
          end
        end

        return vim.lsp.handlers['textDocument/diagnostic'](err, result, ctx)
      end,
    }

    config.filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' }

    config.settings = {
      format = { enable = true },
      workingDirectories = { mode = 'auto' },
      codeAction = {
        disableRuleComment = { enable = false },
        showDocumentation = { enable = true },
      },
    }

    return config
  end,
  install = { 'npm', '@eslint/lsp' },
}
