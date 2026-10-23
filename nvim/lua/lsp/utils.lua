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

return M
