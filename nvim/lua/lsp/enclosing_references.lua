local M = {}

local function item_path(item)
  if item.filename then return vim.fn.fnamemodify(item.filename, ':p') end
  if item.uri then return vim.fn.fnamemodify(vim.uri_to_fname(item.uri), ':p') end
  if item.bufnr and vim.api.nvim_buf_is_valid(item.bufnr) then
    local name = vim.api.nvim_buf_get_name(item.bufnr)
    if name ~= '' then return vim.fn.fnamemodify(name, ':p') end
  end
end

local function item_line(item)
  if item.bufnr and vim.api.nvim_buf_is_valid(item.bufnr) and vim.api.nvim_buf_is_loaded(item.bufnr) then
    local ok, line = pcall(vim.api.nvim_buf_get_lines, item.bufnr, item.lnum - 1, item.lnum, false)
    if ok and line[1] then return line[1] end
  end

  local path = item_path(item)
  if path and vim.fn.filereadable(path) == 1 then
    local ok, lines = pcall(vim.fn.readfile, path, '', item.lnum)
    if ok and lines[item.lnum] then return lines[item.lnum] end
  end

  return item.text or ''
end

local function item_lines(item, start_lnum, end_lnum)
  start_lnum = math.max(start_lnum, 1)
  end_lnum = math.max(end_lnum, start_lnum)

  if item.bufnr and vim.api.nvim_buf_is_valid(item.bufnr) and vim.api.nvim_buf_is_loaded(item.bufnr) then
    local ok, lines = pcall(vim.api.nvim_buf_get_lines, item.bufnr, start_lnum - 1, end_lnum, false)
    if ok then return lines end
  end

  local path = item_path(item)
  if path and vim.fn.filereadable(path) == 1 then
    local ok, lines = pcall(vim.fn.readfile, path, '', end_lnum)
    if ok then return vim.list_slice(lines, start_lnum, end_lnum) end
  end

  return {}
end

-- One name in a multi-line import list: `foo,`, `foo as bar,`, `type Foo,`.
-- (Lua patterns can't make a group optional, hence the separate matches.)
local function is_import_specifier(line)
  line = line:gsub('^%s*type%s+', '')
  return line:match('^%s*[%w_$]+%s*,?%s*$') or line:match('^%s*[%w_$]+%s+as%s+[%w_$]+%s*,?%s*$')
end

---Whether a reference is only an import/re-export of the symbol, not a usage
function M.is_import_reference(item)
  local line = item_line(item)

  if
    line:match('^%s*import%s')
    or line:match('^%s*export%s*{')
    or line:match('^%s*from%s')
    or line:match('^%s*}%s*from%s')
  then
    return true
  end

  if not is_import_specifier(line) then return false end

  local start_lnum = math.max(1, item.lnum - 20)
  local end_lnum = item.lnum + 20
  local lines = item_lines(item, start_lnum, end_lnum)
  local relative_lnum = item.lnum - start_lnum + 1
  local saw_import_start = false
  local saw_import_end = false

  for i = relative_lnum, 1, -1 do
    local candidate = lines[i] or ''
    if candidate:match('^%s*import%s') then
      saw_import_start = true
      break
    end

    if candidate:match(';') or (candidate:match('^%s*%S') and not is_import_specifier(candidate)) then break end
  end

  for i = relative_lnum, #lines do
    local candidate = lines[i] or ''
    if candidate:match('%sfrom%s') or candidate:match('^%s*}%s*from%s') then
      saw_import_end = true
      break
    end
    if i > relative_lnum and candidate:match(';') then break end
  end

  return saw_import_start and saw_import_end
end

local function name_from_declarator(node)
  for child in node:iter_children() do
    if child:type() == 'identifier' then return child end
  end
end

local function name_from_node(node)
  for child in node:iter_children() do
    local child_type = child:type()
    if child_type == 'identifier' or child_type == 'property_identifier' then
      return child
    end

    if child_type == 'variable_declarator' then
      local name_node = name_from_declarator(child)
      if name_node then return name_node end
    end

    if child_type == 'lexical_declaration' or child_type == 'variable_declaration' then
      local name_node = name_from_node(child)
      if name_node then return name_node end
    end
  end
end

-- Arrow functions are named by their enclosing declaration; their own identifier children are parameters
local declaration_types = {
  function_declaration = true,
  lexical_declaration = true,
  export_statement = true,
  variable_declaration = true,
  method_definition = true,
}

---Named declarations around the cursor, nearest first
---@return { name: string, row: integer, col: integer }[]
local function enclosing_declarations()
  local found, seen = {}, {}
  local node = vim.treesitter.get_node()
  while node do
    if declaration_types[node:type()] then
      local name_node = name_from_node(node)
      if name_node then
        local row, col = name_node:range()
        local key = row .. ':' .. col
        if not seen[key] then
          seen[key] = true
          table.insert(found, { name = vim.treesitter.get_node_text(name_node, 0), row = row, col = col })
        end
      end
    end
    node = node:parent()
  end
  return found
end

---@param decl { name: string, row: integer, col: integer }
local function find_usages(decl)
  local save_pos = vim.api.nvim_win_get_cursor(0)

  vim.api.nvim_win_set_cursor(0, { decl.row + 1, decl.col })
  vim.lsp.buf.references(nil, {
    on_list = function(options)
      pcall(vim.api.nvim_win_set_cursor, 0, save_pos)

      local current_file = vim.fn.expand('%:p')
      local filtered = {}
      for _, item in ipairs(options.items) do
        local is_definition = item_path(item) == current_file and item.lnum == decl.row + 1
        if not is_definition and not M.is_import_reference(item) then table.insert(filtered, item) end
      end

      if #filtered == 0 then
        vim.notify('No usages of ' .. decl.name .. ' found', vim.log.levels.WARN)
        return
      end

      if #filtered == 1 then
        require('lsp.utils').jump_to_item(filtered[1])
        return
      end

      vim.fn.setqflist({}, 'r', { title = 'Usages of ' .. decl.name, items = filtered })
      require('fzf-lua').quickfix({ prompt = decl.name .. ' usages> ' })
    end,
  })
end

---Find usages of the enclosing declaration; when nested, pick one (nearest first)
function M.find()
  local decls = enclosing_declarations()

  if #decls == 0 then
    vim.notify('No enclosing function found', vim.log.levels.WARN)
    return
  end

  if #decls == 1 then
    find_usages(decls[1])
    return
  end

  local entries = {}
  for i, decl in ipairs(decls) do
    entries[i] = ('%d\t%s\t:%d'):format(i, decl.name, decl.row + 1)
  end

  require('fzf-lua').fzf_exec(entries, {
    prompt = 'Usages of> ',
    fzf_opts = { ['--delimiter'] = '\t', ['--with-nth'] = '2..', ['--no-sort'] = true },
    actions = {
      ['default'] = function(selected)
        local index = selected[1] and tonumber(selected[1]:match('^(%d+)'))
        if index then find_usages(decls[index]) end
      end,
    },
  })
end

return M
