---@class ClientConfig: lspconfig.Config
---@field root_dir string | function

---@class (exact) LspServer
---@field config? fun(config: ClientConfig): ClientConfig
---@field display? string
---@field skip_lspconfig? boolean

---@type table<string, LspServer>
local servers = {
  clangd = {},
  emmet_language_server = require('lsp.servers.emmet_language_server'),
  eslint = require('lsp.servers.eslint'),
  -- graphql = require('lsp.servers.graphql'),
  html = require('lsp.servers.html'),
  pyright = {},
  tailwindcss = require('lsp.servers.tailwindcss'),
  -- ["typescript-tools"] = require("lsp.servers.typescript-tools"),
  rust_analyzer = {},
  -- jsonls is manually configured in lua/plugins/lsp.lua
  jsonls = require('lsp.servers.jsonls'),
  lua_ls = require('lsp.servers.lua_ls'),
  cssls = {},
  -- ts_ls = {}, -- Disabled: using typescript-tools instead
  vimls = {},
  yamlls = {},
}

local supported_servers = {}
if MY_CONFIG and not vim.tbl_isempty(MY_CONFIG.supported_servers) then
  for _, server_name in ipairs(MY_CONFIG.supported_servers) do
    if servers[server_name] then
      supported_servers[server_name] = servers[server_name]
    end
  end
else
  supported_servers = servers
end

return supported_servers

-- vim:foldmethod=marker foldlevel=0
