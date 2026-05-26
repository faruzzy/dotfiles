---Common LSP on_attach function
---Sets up buffer-local keymaps and settings for LSP

local lightbulb_ns = vim.api.nvim_create_namespace('lightbulb')
local code_action_icon = vim.trim(require('config.theme').icons.code_action or '󰌵')

local function enable_inlay_hints(client, bufnr)
  if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, bufnr) then
    pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })

    vim.defer_fn(function()
      if
        vim.api.nvim_buf_is_valid(bufnr)
        and vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
        and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, bufnr)
      then
        pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
      end
    end, 250)
  end
end

---@param client vim.lsp.Client
---@param bufnr number
return function(client, bufnr)
  local bsk = require('utils').buffer_map(bufnr)

  -- LSP actions (gd is handled by fzf-lua with jump-on-single-result)
  bsk('n', '<Leader>rn', vim.lsp.buf.rename, { desc = 'LSP Rename' })
  bsk('n', '<Leader>ca', vim.lsp.buf.code_action, { desc = 'LSP Code Action' })

  enable_inlay_hints(client, bufnr)

  if client:supports_method('textDocument/codeAction', bufnr) then
    local last_lightbulb_line = -1
    local last_lightbulb_tick = -1
    local function clear_lightbulb()
      vim.api.nvim_buf_clear_namespace(bufnr, lightbulb_ns, 0, -1)
      last_lightbulb_line = -1
      last_lightbulb_tick = -1
    end

    require('utils').augroup('lightbulb_' .. bufnr, {
      {
        { 'CursorMoved', 'CursorMovedI', 'InsertEnter' },
        callback = clear_lightbulb,
        buffer = bufnr,
      },
      {
        'CursorHold',
        callback = function()
          local line = vim.api.nvim_win_get_cursor(0)[1] - 1
          local tick = vim.api.nvim_buf_get_changedtick(bufnr)
          if line == last_lightbulb_line and tick == last_lightbulb_tick then
            return
          end
          last_lightbulb_line = line
          last_lightbulb_tick = tick

          local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
          ---@diagnostic disable-next-line: inject-field
          params.context = { diagnostics = vim.diagnostic.get(bufnr, { lnum = line }) }

          vim.lsp.buf_request_all(bufnr, 'textDocument/codeAction', params, function(response)
            vim.api.nvim_buf_clear_namespace(bufnr, lightbulb_ns, 0, -1)

            local has_code_actions = #vim.tbl_filter(function(resp) return resp.result and #resp.result > 0 end, response) > 0

            if has_code_actions then
              vim.api.nvim_buf_set_extmark(bufnr, lightbulb_ns, line, 0, {
                sign_text = code_action_icon,
                sign_hl_group = 'DiagnosticSignHint',
                priority = 20,
              })
            end
          end)
        end,
        buffer = bufnr,
      },
    })
  end
end
