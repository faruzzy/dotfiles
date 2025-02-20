-- Lightweight yet powerful formatter plugin for Neovim
local prettier = { 'prettierd', 'prettier', stop_after_first = true }
local utils = require('utils')

---@class (exact) FormatterConfig
---@field install_cmd? InstallCommand
---@field required_file? string
---@field filetypes string[]

---@type table<string, FormatterConfig>
local formatters = {
  ['clang-format'] = {
    install_cmd = { 'brew', 'clang-format' },
    filetypes = { 'c' },
  },
  ['format-queries'] = { filetypes = { 'query' } },
  prettierd = {
    install_cmd = { 'npm', '@fsouza/prettierd' },
    required_file = './node_modules/.bin/prettier',
    filetypes = {
      'css',
      'graphql',
      'html',
      'javascript',
      'javascriptreact',
      'json',
      'jsonc',
      'less',
      'markdown',
      'scss',
      'svelte',
      'typescript',
      'typescriptreact',
    },
  },
  stylua = {
    install_cmd = { 'cargo', 'stylua' },
    required_file = './stylua.toml',
    filetypes = { 'lua' },
  },
  swiftformat = {
    install_cmd = { 'brew', 'swiftformat' },
    filetypes = { 'swift' },
  },
}

local supported_formatters = vim.g.supported_formatters
    and utils.filter_table_by_keys(formatters, vim.g.supported_formatters)
  or formatters

return {
  'stevearc/conform.nvim',
  event = 'BufWritePre',
  -- config = function()
  --   local conform = require('conform')
  --   conform.setup({
  --     log_level = vim.log.levels.DEBUG,
  --     formatters_by_ft = {
  --       javascript = { 'prettierd', 'prettier' },
  --       typescript = { 'prettierd', 'prettier' },
  --       typescriptreact = { 'prettierd', 'prettier' },
  --     },
  --   })
  -- end,
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
      -- markdown = function(bufnr) return { first(bufnr, "prettierd", "prettier"), "injected" } end,
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
      -- Dealing with old version of prettierd that doesn't support range formatting
      prettierd = {
        ---@diagnostic disable-next-line: assign-type-mismatch
        range_args = false,
      },
    },
    log_level = vim.log.levels.TRACE,
    format_after_save = function(bufnr)
      if vim.b[bufnr].disable_autoformat then
        return
      end
      return { timeout_ms = 5000, lsp_format = 'fallback' }
    end,
  },
  -- opts = function()
  --   local customized_formatters = {}
  --   for name, formatter in pairs(supported_formatters) do
  --     if formatter.required_file then
  --       customized_formatters[name] = {
  --         require_cwd = true,
  --         cwd = require('conform.util').root_file(formatter.required_file),
  --       }
  --     end
  --   end

  --   local formatters_by_ft = {}
  --   for name, formatter in pairs(supported_formatters) do
  --     for _, ft in ipairs(formatter.filetypes) do
  --       local curr_formatters = formatters_by_ft[ft] or {}
  --       table.insert(curr_formatters, name)
  --       formatters_by_ft[ft] = curr_formatters
  --     end
  --   end

  --   return {
  --     default_format_opts = { lsp_format = 'fallback' },
  --     undojoin = true,
  --     formatters = customized_formatters,
  --     formatters_by_ft = formatters_by_ft,
  --     format_on_save = {},
  --   }
  -- end,
  -- init = function()
  --   local install_cmds = {}
  --   for formatter, data in pairs(supported_formatters) do
  --     if data.install_cmd then
  --       install_cmds[formatter] = data.install_cmd
  --     end
  --   end

  --   require('installer').register('formatters', install_cmds, vim.fn.stdpath('data') .. '/formatters')
  -- end,
}
