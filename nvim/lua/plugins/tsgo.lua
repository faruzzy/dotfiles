-- tsgo: native TypeScript LSP plus TypeScript-specific commands

local ts_filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' }
local local_checkout = vim.fn.expand('~/github/tsgo.nvim')

-- Resolve tsgo even when nvim is launched without mise on PATH (e.g. from a GUI)
local function tsgo_cmd()
  local args = { '--lsp', '-stdio' }
  local executable = vim.fn.exepath('tsgo')
  if executable ~= '' then
    return vim.list_extend({ executable }, args)
  end

  if vim.fn.executable('mise') == 1 then
    local result = vim.system({ 'mise', 'which', 'tsgo' }, { text = true }):wait()
    local mise_executable = result.stdout and vim.trim(result.stdout) or ''
    if result.code == 0 and mise_executable ~= '' then
      return vim.list_extend({ mise_executable }, args)
    end
  end

  local mise_installs = vim.fn.glob(vim.fn.expand('~') .. '/.local/share/mise/installs/node/*/bin/tsgo', false, true)
  table.sort(mise_installs)
  for index = #mise_installs, 1, -1 do
    if vim.fn.executable(mise_installs[index]) == 1 then
      return vim.list_extend({ mise_installs[index] }, args)
    end
  end

  return vim.list_extend({ 'tsgo' }, args)
end

return {
  'faruzzy/tsgo.nvim',
  -- Use the local checkout when present, otherwise install from GitHub
  dir = vim.fn.isdirectory(local_checkout) == 1 and local_checkout or nil,
  ft = ts_filetypes,
  -- LSP setup, root detection and inlay hint settings come from the plugin defaults
  opts = function()
    return {
      cmd = tsgo_cmd(),
      keymaps = {
        enable = true,
        organize_imports = '<leader>io',
        add_missing_imports = '<leader>ia',
        remove_unused = '<leader>ir',
        fix_all = '<leader>if',
        imports = '<leader>ii',
        source_definition = 'gD',
      },
    }
  end,
  config = function(_, opts)
    require('tsgo').setup(opts)
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('tsgo_attach', { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or client.name ~= 'tsgo' then
          return
        end

        -- Disable formatting (conform.nvim handles it)
        client.server_capabilities.documentFormattingProvider = false

        -- tsgo advertises willRenameFiles, but currently returns an empty response
        -- often enough to trigger nvim-lsp-file-operations timeout warnings.
        if client.server_capabilities.workspace and client.server_capabilities.workspace.fileOperations then
          client.server_capabilities.workspace.fileOperations.willRename = nil
        end

        local bufnr = args.buf
        local bsk = require('utils').buffer_map(bufnr)

        bsk('n', 'gR', function() require('lsp.enclosing_references').find() end, { desc = 'Find references to enclosing function' })
      end,
    })
  end,
}
