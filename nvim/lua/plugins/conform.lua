local prettier = { 'prettierd', 'prettier', stop_after_first = true }

return {
  'stevearc/conform.nvim',
  event = 'BufWritePre',
  opts = {
    default_format_opts = {
      lsp_format = 'fallback',
    },
    formatters_by_ft = {
      javascript = prettier,
      typescript = prettier,
      javascriptreact = prettier,
      typescriptreact = prettier,
      css = prettier,
      graphql = prettier,
      html = prettier,
      json = { 'prettierd', 'prettier', 'jq', stop_after_first = true },
      json5 = prettier,
      jsonc = prettier,
      yaml = prettier,
      markdown = { 'injected' },
      norg = { 'injected' },
      lua = { 'stylua' },
      go = { 'goimports', 'gofmt' },
      query = { 'format-queries' },
      sh = { 'shfmt' },
      python = { 'isort', 'black' },
      zig = { 'zigfmt' },
      ['_'] = { 'trim_whitespace', 'trim_newlines' },
    },
    formatters = {
      injected = {
        options = {
          lang_to_formatters = {
            html = {},
          },
        },
      },
      prettierd = {
        ---@diagnostic disable-next-line: assign-type-mismatch
        range_args = false,
      },
    },
    log_level = vim.log.levels.TRACE,
    format_after_save = function(bufnr)
      if vim.b[bufnr].disable_autoformat then return end
      return { timeout_ms = 5000, lsp_format = 'fallback' }
    end,
  },
}
