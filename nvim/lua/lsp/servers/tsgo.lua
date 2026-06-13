local function tsgo_cmd()
  local executable = vim.fn.exepath('tsgo')
  if executable ~= '' then
    return { executable, '--lsp', '-stdio' }
  end

  if vim.fn.executable('mise') == 1 then
    local result = vim.system({ 'mise', 'which', 'tsgo' }, { text = true }):wait()
    local mise_executable = result.stdout and vim.trim(result.stdout) or ''
    if result.code == 0 and mise_executable ~= '' then
      return { mise_executable, '--lsp', '-stdio' }
    end
  end

  local mise_installs = vim.fn.glob(vim.fn.expand('~') .. '/.local/share/mise/installs/node/*/bin/tsgo', false, true)
  table.sort(mise_installs)
  for index = #mise_installs, 1, -1 do
    if vim.fn.executable(mise_installs[index]) == 1 then
      return { mise_installs[index], '--lsp', '-stdio' }
    end
  end

  return { 'tsgo', '--lsp', '-stdio' }
end

local function tsgo_settings()
  local ok, config = pcall(require, 'tsgo.config')
  if ok then
    return config.defaults.settings
  end

  local inlay_hints = {
    parameterNames = { enabled = 'literals' },
    parameterTypes = { enabled = false },
    variableTypes = { enabled = false },
    propertyDeclarationTypes = { enabled = false },
    functionLikeReturnTypes = { enabled = false },
    enumMemberValues = { enabled = true },
  }

  return {
    typescript = { inlayHints = inlay_hints },
    javascript = { inlayHints = inlay_hints },
  }
end

return {
  cmd = tsgo_cmd(),
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  settings = tsgo_settings(),
}
