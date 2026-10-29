local flat_configs = {
  'eslint.config.js',
  'eslint.config.mjs',
  'eslint.config.cjs',
  'eslint.config.ts',
  'eslint.config.mts',
  'eslint.config.cts',
}

return {
  cmd = { 'vscode-eslint-language-server', '--stdio' },
  -- Groups are searched in priority order (nearest match within a group wins). Flat configs
  -- go first so the global fallback ~/.eslintrc (symlinked from dotfiles) can't outrank a
  -- project's eslint.config.* and make $HOME the root.
  root_markers = {
    flat_configs,
    { '.eslintrc', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.yaml', '.eslintrc.yml', '.eslintrc.json' },
    { 'package.json', '.git' },
  },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
  -- vscode-eslint-language-server needs the workspace folder in its settings, or every
  -- diagnostic request fails with 'The "path" argument must be of type string'.
  -- nvim-lspconfig normally injects this; this config doesn't use it.
  before_init = function(_, config)
    local root = config.root_dir
    if not root then
      return
    end
    config.settings.workspaceFolder = { uri = vim.uri_from_fname(root), name = vim.fn.fnamemodify(root, ':t') }
    for _, name in ipairs(flat_configs) do
      if vim.uv.fs_stat(root .. '/' .. name) then
        config.settings.experimental = { useFlatConfig = true }
        break
      end
    end
  end,
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, 'EslintFixAll', function()
      -- The first fix in a fresh buffer loads ESLint, its plugins and the TS parser, which can
      -- outlast request_sync's 1s default and silently do nothing
      local response, err = client:request_sync('workspace/executeCommand', {
        command = 'eslint.applyAllFixes',
        arguments = { { uri = vim.uri_from_bufnr(bufnr), version = vim.lsp.util.buf_versions[bufnr] } },
      }, 10000, bufnr)
      if not response then
        vim.notify('ESLint fix all: ' .. (err or 'no response'), vim.log.levels.WARN)
      end
    end, { desc = 'ESLint: fix all auto-fixable problems' })

    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      group = vim.api.nvim_create_augroup('eslint_fix_' .. bufnr, { clear = true }),
      callback = function()
        -- Skip the blocking fix request when ESLint reports nothing. Match on source: its pull
        -- diagnostics don't land in vim.lsp.diagnostic.get_namespace(client.id, true)
        local has_problems = vim.iter(vim.diagnostic.get(bufnr)):any(function(d)
          return (d.source or ''):lower() == 'eslint'
        end)
        if has_problems and vim.fn.exists(':EslintFixAll') == 2 then
          vim.cmd.EslintFixAll()
        end
      end,
    })
    require('utils').buffer_map(bufnr)('n', '<leader>ef', '<cmd>EslintFixAll<cr>', { desc = 'ESLint Fix All' })
  end,
  handlers = {
    ['window/showMessageRequest'] = function(err, result, ctx)
      if result and result.message and result.message:find('Unable to find ESLint library') then
        return vim.NIL
      end
      return vim.lsp.handlers['window/showMessageRequest'](err, result, ctx)
    end,
    -- Custom requests the server sends; answer them so it doesn't stall or log errors
    ['eslint/confirmESLintExecution'] = function(_, result)
      return result and 4 or nil -- 4 = approved
    end,
    ['eslint/probeFailed'] = function()
      vim.notify('ESLint probe failed', vim.log.levels.WARN)
      return {}
    end,
    ['eslint/noLibrary'] = function()
      return {}
    end,
    ['eslint/openDoc'] = function(_, result)
      if result and result.url then
        vim.ui.open(result.url)
      end
      return {}
    end,
    ['textDocument/diagnostic'] = function(err, result, ctx)
      if result and result.items then
        for _, item in ipairs(result.items) do
          item.severity = item.severity == 1 and 1 or item.severity == 2 and 2 or 4
        end
      end
      return vim.lsp.handlers['textDocument/diagnostic'](err, result, ctx)
    end,
  },
  settings = {
    validate = 'on',
    run = 'onType',
    format = { enable = true },
    quiet = false,
    onIgnoredFiles = 'off',
    useESLintClass = false,
    nodePath = '',
    rulesCustomizations = {},
    problems = { shortenToSingleLine = false },
    codeActionOnSave = { enable = false, mode = 'all' },
    experimental = { useFlatConfig = false },
    workingDirectory = { mode = 'location' },
    codeAction = {
      disableRuleComment = { enable = false },
      showDocumentation = { enable = true },
    },
  },
}
