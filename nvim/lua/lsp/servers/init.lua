-- lsp/servers/init.lua
-- This file combines all individual server configurations

return {
  -- Language servers
  lua_ls = require('lsp.servers.lua_ls'),
  html = require('lsp.servers.html'),
  cssls = require('lsp.servers.cssls'),
  jsonls = require('lsp.servers.jsonls'),
  eslint = require('lsp.servers.eslint'),
  emmet_language_server = require('lsp.servers.emmet_language_server'),
  graphql = require('lsp.servers.graphql'),
  pyright = require('lsp.servers.pyright'),
  rust_analyzer = require('lsp.servers.rust_analyzer'),
  tailwindcss = require('lsp.servers.tailwindcss'),
  svelte = require('lsp.servers.svelte'),
  vimls = require('lsp.servers.vimls'),
  yamlls = require('lsp.servers.yamlls'),
  clangd = require('lsp.servers.clangd'),
  -- Add any other servers you have
}
