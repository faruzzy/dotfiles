-- tsgo: native TypeScript LSP plus TypeScript-specific commands

local ts_filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' }
local local_checkout = vim.fn.expand('~/github/tsgo.nvim')

return {
  'faruzzy/tsgo.nvim',
  -- Use the local checkout when present, otherwise install from GitHub
  dir = vim.fn.isdirectory(local_checkout) == 1 and local_checkout or nil,
  ft = ts_filetypes,
  -- LSP setup, cmd resolution, root detection and inlay hint settings come from the plugin defaults
  opts = {
    keymaps = {
      enable = true,
      organize_imports = '<leader>io',
      add_missing_imports = '<leader>ia',
      remove_unused = '<leader>ir',
      fix_all = '<leader>if',
      imports = '<leader>ii',
      source_definition = 'gD',
    },
  },
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
