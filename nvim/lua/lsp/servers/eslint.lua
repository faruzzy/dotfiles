return {
  root_markers = {
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
  },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
  on_attach = function(_, bufnr)
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      group = vim.api.nvim_create_augroup('eslint_fix_' .. bufnr, { clear = true }),
      callback = function()
        if vim.fn.exists(':EslintFixAll') == 2 then
          vim.cmd.EslintFixAll()
        end
      end,
    })
    require('utils').buffer_map(bufnr)('n', '<leader>ef', '<cmd>EslintFixAll<cr>', { desc = 'ESLint Fix All' })
  end,
  handlers = {
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
  },
  settings = {
    format = { enable = true },
    workingDirectories = { mode = 'auto' },
    codeAction = {
      disableRuleComment = { enable = false },
      showDocumentation = { enable = true },
    },
  },
}
