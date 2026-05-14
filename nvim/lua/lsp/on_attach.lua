---Common LSP on_attach function
---Sets up buffer-local keymaps and settings for LSP

local lightbulb_ns = vim.api.nvim_create_namespace('lightbulb')

---@param client vim.lsp.Client
---@param bufnr number
return function(client, bufnr)
  local bsk = require('utils').buffer_map(bufnr)

  -- LSP actions (gd is handled by fzf-lua with jump-on-single-result)
  bsk('n', '<Leader>rn', vim.lsp.buf.rename, { desc = 'LSP Rename' })
  bsk('n', '<Leader>ca', vim.lsp.buf.code_action, { desc = 'LSP Code Action' })

  -- Disabled: Neovim 0.12.x has a bug where inlay hint extmarks crash with
  -- "Invalid 'col': out of range". Toggle manually with <Leader>ih instead.
  -- if client:supports_method('textDocument/inlayHint', bufnr) then
  --   vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  -- end
  if client:supports_method('textDocument/inlayHint', bufnr) then vim.lsp.inlay_hint.enable(true, { bufnr = bufnr }) end

  if client:supports_method('textDocument/codeAction', bufnr) then
    local last_lightbulb_line = -1
    local last_lightbulb_tick = -1
    require('utils').augroup('lightbulb_' .. bufnr, {
      {
        'CursorHold',
        callback = function()
          local line = vim.api.nvim_win_get_cursor(0)[1] - 1
          local tick = vim.api.nvim_buf_get_changedtick(bufnr)
          if line == last_lightbulb_line and tick == last_lightbulb_tick then return end
          last_lightbulb_line = line
          last_lightbulb_tick = tick

          local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
          ---@diagnostic disable-next-line: inject-field
          params.context = { diagnostics = vim.diagnostic.get(bufnr, { lnum = line }) }

          vim.lsp.buf_request_all(bufnr, 'textDocument/codeAction', params, function(response)
            vim.api.nvim_buf_clear_namespace(bufnr, lightbulb_ns, 0, -1)

            local has_code_actions = #vim.tbl_filter(
              function(resp) return resp.result and #resp.result > 0 end,
              response
            ) > 0

            if has_code_actions then
              vim.api.nvim_buf_set_extmark(bufnr, lightbulb_ns, line, -1, {
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
