-- gd / gr: LSP definitions and references, filtered, shown in fzf-lua when there's more than one
local M = {}

local function is_node_modules_declaration(item)
  local filename = item.filename or ''
  return filename:match('/node_modules/') and filename:match('%.d%.ts$')
end

local function prefer_source_definitions(items)
  local source_items = vim.tbl_filter(function(item) return not is_node_modules_declaration(item) end, items)
  if #source_items > 0 then
    return source_items
  end
  return items
end

---Definitions, deduplicated and preferring source over node_modules .d.ts; jumps when there's one
function M.definitions()
  vim.lsp.buf.definition({
    on_list = function(options)
      local seen = {}
      local items = {}
      for _, item in ipairs(options.items) do
        local key = item.filename .. ':' .. item.lnum
        if not seen[key] then
          seen[key] = true
          table.insert(items, item)
        end
      end
      items = prefer_source_definitions(items)

      if #items == 0 then
        vim.notify('No definitions found', vim.log.levels.WARN)
      elseif #items == 1 then
        require('lsp.utils').jump_to_item(items[1])
      else
        vim.fn.setqflist({}, 'r', { title = options.title, items = items })
        require('fzf-lua').quickfix({ prompt = 'Definitions> ' })
      end
    end,
  })
end

---References, minus the cursor position and import/re-export lines
function M.references()
  local current_file = vim.fn.expand('%:p')
  local current_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = current_pos[1]
  local current_col = current_pos[2]

  vim.lsp.buf.references(nil, {
    on_list = function(options)
      -- Filter the items
      local filtered_items = {}
      for _, item in ipairs(options.items) do
        -- Skip current cursor position
        local is_current_position = (
          item.filename == current_file
          and item.lnum == current_line
          and math.abs((item.col or 1) - current_col - 1) <= 1
        )

        -- Skip imports/re-exports, but keep usages like `export const x = useThing()`
        if not is_current_position and not require('lsp.enclosing_references').is_import_reference(item) then
          table.insert(filtered_items, item)
        end
      end

      if #filtered_items == 0 then
        vim.notify('No other references found', vim.log.levels.WARN)
        return
      end

      -- Jump directly if only one result
      if #filtered_items == 1 then
        require('lsp.utils').jump_to_item(filtered_items[1])
        return
      end

      -- Set quickfix list and use fzf-lua
      vim.fn.setqflist({}, 'r', {
        title = 'References (filtered)',
        items = filtered_items,
      })

      require('fzf-lua').quickfix({
        prompt = 'References (filtered)> ',
      })
    end,
  })
end

return M
