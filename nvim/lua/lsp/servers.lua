--- Server configurations for vim.lsp.config()
--- Each entry returns a table compatible with vim.lsp.config(name, config)

---@type table<string, table>
local servers = {
  clangd = {
    cmd = { 'clangd' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
    root_markers = { '.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json', 'compile_flags.txt' },
  },
  cssls = {
    cmd = { 'vscode-css-language-server', '--stdio' },
    filetypes = { 'css', 'scss', 'less' },
    root_markers = { 'package.json', '.git' },
  },
  emmet_language_server = require('lsp.servers.emmet_language_server'),
  eslint = require('lsp.servers.eslint'),
  gopls = {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_markers = { 'go.work', 'go.mod', '.git' },
  },
  -- graphql = require('lsp.servers.graphql'),
  html = require('lsp.servers.html'),
  jsonls = require('lsp.servers.jsonls'),
  lua_ls = require('lsp.servers.lua_ls'),
  pyright = {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'pyrightconfig.json' },
  },
  rust_analyzer = {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml', 'rust-project.json' },
  },
  tailwindcss = require('lsp.servers.tailwindcss'),
  vimls = {
    cmd = { 'vim-language-server', '--stdio' },
    filetypes = { 'vim' },
    root_markers = { '.git' },
  },
  tsgo = require('lsp.servers.tsgo'),
  yamlls = {
    cmd = { 'yaml-language-server', '--stdio' },
    filetypes = { 'yaml', 'yaml.docker-compose' },
    root_markers = { '.git' },
  },
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
