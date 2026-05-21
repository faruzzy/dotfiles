--- Server configurations for vim.lsp.config()
--- Each entry returns a table compatible with vim.lsp.config(name, config)

---@type table<string, table>
local servers = {
  clangd = {},
  cssls = {},
  emmet_language_server = require('lsp.servers.emmet_language_server'),
  eslint = require('lsp.servers.eslint'),
  -- graphql = require('lsp.servers.graphql'),
  html = require('lsp.servers.html'),
  jsonls = require('lsp.servers.jsonls'),
  lua_ls = require('lsp.servers.lua_ls'),
  pyright = {},
  rust_analyzer = {},
  tailwindcss = require('lsp.servers.tailwindcss'),
  vimls = {},
  vtsls = require('lsp.servers.vtsls'),
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
