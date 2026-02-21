---Common LSP on_attach function
---Sets up buffer-local keymaps and settings for LSP
---@param client vim.lsp.Client
---@param bufnr number

local lightbulb_ns = vim.api.nvim_create_namespace('lightbulb')

return function(client, bufnr)
  local bsk = require('utils').buffer_map(bufnr)

  -- LSP actions (gd is handled by fzf-lua with jump-on-single-result)
  bsk('n', '<Leader>rn', vim.lsp.buf.rename, { desc = 'LSP Rename' })
  bsk('n', '<Leader>ca', vim.lsp.buf.code_action, { desc = 'LSP Code Action' })

  -- Inlay hints available but not auto-enabled due to Neovim 0.11.x
  -- rendering bug (Invalid 'col': out of range). Use <Leader>ti to toggle.

  if client.supports_method('textDocument/codeAction') then
    require('utils').augroup('lightbulb_' .. bufnr, {
      {
        { 'CursorHold', 'CursorHoldI' },
        callback = function()
          local params = vim.lsp.util.make_range_params()
          params.context = { diagnostics = vim.diagnostic.get(bufnr, { lnum = params.range.start.line }) }

          vim.lsp.buf_request_all(bufnr, 'textDocument/codeAction', params, function(response)
            vim.api.nvim_buf_clear_namespace(bufnr, lightbulb_ns, 0, -1)

            local has_code_actions = #vim.tbl_filter(function(resp)
              return resp.result and #resp.result > 0
            end, response) > 0

            if has_code_actions then
              vim.api.nvim_buf_set_extmark(bufnr, lightbulb_ns, params.range.start.line, -1, {
                virt_text = { { '💡' } },
                hl_mode = 'combine',
              })
            end
          end)
        end,
        buffer = bufnr,
      },
    })
  end
end
