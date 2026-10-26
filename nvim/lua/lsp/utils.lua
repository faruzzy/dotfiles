local M = {}

---Configure auto-close tag support for HTML & Svelte servers
---@param client vim.lsp.Client
---@param bufnr number
---@param method string
function M.setup_auto_close_tag(client, bufnr, method)
  local bsk = require('utils').buffer_map(bufnr)

  local function auto_insert(key)
    return function()
      vim.schedule(function()
        client:request(
          method,
          vim.tbl_extend('force', vim.lsp.util.make_position_params(0, client.offset_encoding), { kind = 'autoClose' }),
          function(_, result)
            if result then vim.snippet.expand(result) end
          end,
          bufnr
        )
      end)

      return key
    end
  end

  bsk('i', '>', auto_insert('>'), { expr = true })
  bsk('i', '/', auto_insert('/'), { expr = true })
end

---Jump to a quickfix-style LSP location item in the current window (adds a jumplist entry)
---@param item vim.quickfix.entry
function M.jump_to_item(item)
  local bufnr = item.bufnr
  if not (bufnr and vim.api.nvim_buf_is_valid(bufnr)) then
    if not item.filename then return end
    bufnr = vim.fn.bufadd(item.filename)
  end
  vim.fn.bufload(bufnr)
  vim.bo[bufnr].buflisted = true
  vim.cmd("normal! m'")
  vim.api.nvim_win_set_buf(0, bufnr)
  -- The server's line can be past the end when the buffer differs from what it indexed
  local lnum = math.min(item.lnum, vim.api.nvim_buf_line_count(bufnr))
  pcall(vim.api.nvim_win_set_cursor, 0, { lnum, math.max((item.col or 1) - 1, 0) })
  vim.cmd('normal! zv')
end

return M
