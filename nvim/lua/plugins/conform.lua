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
      go = { 'goimports', 'gofmt', stop_after_first = true },
      proto = { 'buf' },
      query = { 'format-queries' },
      sh = { 'shfmt' },
      python = { 'isort', 'black' },
      zig = { 'zigfmt' },
      -- Then the language server formats, if one can (clangd, ruby-lsp, rust-analyzer…); with the
      -- default 'fallback', these trims would count as formatters and the server would never run
      ['_'] = { 'trim_whitespace', 'trim_newlines', lsp_format = 'last' },
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
    format_on_save = function(bufnr)
      if vim.b[bufnr].disable_autoformat then return end
      if vim.fs.basename(vim.api.nvim_buf_get_name(bufnr)) == 'lazy-lock.json' then return end
      -- No lsp_format here: an explicit one overrides the per-filetype one in formatters_by_ft
      return { timeout_ms = 5000 }
    end,
  },
}
