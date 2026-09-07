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
  local inlay_hints = {
    parameterNames = { enabled = 'all' },
    parameterTypes = { enabled = false },
    variableTypes = { enabled = false },
    propertyDeclarationTypes = { enabled = false },
    functionLikeReturnTypes = { enabled = false },
    enumMemberValues = { enabled = true },
  }

  local ok, config = pcall(require, 'tsgo.config')
  if ok then
    return vim.tbl_deep_extend('force', config.defaults.settings, {
      typescript = { inlayHints = inlay_hints },
      javascript = { inlayHints = inlay_hints },
    })
  end

  return {
    typescript = { inlayHints = inlay_hints },
    javascript = { inlayHints = inlay_hints },
  }
end

local function tsgo_root_dir(bufnr, on_dir)
  local name = vim.api.nvim_buf_get_name(bufnr)
  local startpath = name ~= '' and name or vim.fn.getcwd()
  local startdir = vim.fs.dirname(startpath)

  local marker = vim.fs.find({ 'tsconfig.json', 'jsconfig.json' }, {
    upward = true,
    path = startdir,
  })[1]

  if not marker then
    return
  end

  local root = vim.fs.dirname(marker)
  local boundary_marker = vim.fs.find({ 'package.json', '.git' }, {
    upward = true,
    path = startdir,
  })[1]

  if boundary_marker then
    local boundary = vim.fs.dirname(boundary_marker)
    if root ~= boundary and root:sub(1, #boundary + 1) ~= boundary .. '/' then
      return
    end
  end

  on_dir(root)
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
  root_dir = tsgo_root_dir,
  settings = tsgo_settings(),
}
