---@type LspServer
return {
  display = 'ts-tools',
  install = { 'npm', 'install', '-g', 'typescript@5.5.0', 'typescript-svelte-plugin@0.4.0' },   -- Pin versions
  fallback = { 'yarn', 'global', 'add', 'typescript@5.5.0', 'typescript-svelte-plugin@0.4.0' }, -- Fallback
  skip_lspconfig = true,
}
