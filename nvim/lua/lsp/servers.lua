---@class ClientConfig: lspconfig.Config
---@field root_dir string | function

---@class (exact) LspServer
---@field config? fun(config: ClientConfig): ClientConfig
---@field display? string
---@field install? InstallCommand
---@field skip_lspconfig? boolean

---@type table<string, LspServer>
local servers = {
  clangd = { install = { 'brew', 'llvm' } },
  emmet_language_server = require('lsp.servers.emmet_language_server'),
  eslint = require('lsp.servers.eslint'),
  graphql = require('lsp.servers.graphql'),
  html = require('lsp.servers.html'),
  pyright = { install = { 'npm', 'pyright' } },
  tailwindcss = require('lsp.servers.tailwindcss'),
  -- ["typescript-tools"] = require("lsp.servers.typescript-tools"),
  rust_analyzer = {},
  jsonls = require('lsp.servers.jsonls'),
  lua_ls = require('lsp.servers.lua_ls'),
  cssls = { install = { 'npm', 'vscode-langservers-extracted' } },
  -- ts_ls = {},
  vimls = { install = { 'npm', 'vim-language-server' } },
  yamlls = { install = { 'npm', 'yaml-language-server' } },
}

-- for server_name, config in pairs(vim.g.additional_servers) do
-- 	servers[server_name] = config.server
-- end

local supported_servers = {}
if vim.g.supported_servers then
  for _, server_name in ipairs(vim.g.supported_servers) do
    if servers[server_name] then
      supported_servers[server_name] = servers[server_name]
    end
  end
else
  supported_servers = servers
end

local install_cmds = {}
for server, data in pairs(supported_servers) do
  if data.install then
    install_cmds[server] = data.install
  end
end
require('installer').register('lsp', install_cmds, vim.fn.stdpath('data') .. '/lsp-servers')

return supported_servers

-- vim:foldmethod=marker foldlevel=0
