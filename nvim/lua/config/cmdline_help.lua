-- :help excerpts as documentation for blink.cmp's cmdline completions.
-- Used as the cmdline provider's resolve override; the completion type nvim reports for the
-- cursor position decides which help tag an item maps to (:cmd, 'option', fn(), ...).
local M = {}

local MAX_LINES = 40

---@type table<string, { path: string }>?
local tags
local tags_key
---@type table<string, string[]>
local files = {}

-- Index every doc/tags file on the runtimepath; rebuilt when lazy-loaded plugins add more
local function tag_index()
  local tag_files = vim.api.nvim_get_runtime_file('doc/tags', true)
  local key = table.concat(tag_files, ',')
  if tags and key == tags_key then
    return tags
  end
  tags, tags_key = {}, key
  for _, tag_file in ipairs(tag_files) do
    local dir = vim.fs.dirname(tag_file)
    for _, line in ipairs(vim.fn.readfile(tag_file)) do
      local tag, file = line:match('^([^\t]+)\t([^\t]+)\t')
      -- First one wins, like :help (Neovim's own docs come first on the runtimepath)
      if tag and not tags[tag] then
        tags[tag] = { path = dir .. '/' .. file }
      end
    end
  end
  return tags
end

---@param text string completed text
---@param type string getcmdcompltype()
---@return string[]
local function candidates(text, type)
  if type == 'command' then
    return { ':' .. text }
  end
  if type == 'option' then
    local name = text:gsub('^&', ''):gsub('^[lg]:', '')
    return { '\'' .. name .. '\'', '\'' .. name:gsub('^no', '') .. '\'', '\'' .. name:gsub('^inv', '') .. '\'' }
  end
  if type == 'function' or type == 'expression' then
    local name = text:gsub('%(%)?$', '')
    return { name .. '()', name }
  end
  if type == 'lua' then
    local name = text:gsub('^=', '')
    local list = { name .. '()', name }
    -- vim.api.nvim_* and vim.fn.* are documented under their bare names
    local api = name:match('^vim%.api%.(.+)') or name:match('^vim%.fn%.(.+)')
    if api then
      vim.list_extend(list, { api .. '()', api })
    end
    return list
  end
  if type == 'help' or type == 'event' then
    return { text }
  end
  if type == 'highlight' then
    return { 'hl-' .. text }
  end
  return {}
end

-- A line made only of *tag* targets (the right-aligned ones above an entry)
local function tags_only(line) return line:gsub('%*[^%s*]+%*', ''):match('^%s*$') ~= nil end

---@param tag string
---@return string[]?
local function excerpt(tag, path)
  files[path] = files[path] or vim.fn.readfile(path)
  local lines = files[path]
  local needle = '*' .. tag .. '*'
  for i, line in ipairs(lines) do
    if line:find(needle, 1, true) then
      -- Right-aligned tags would stretch the window to the help file's 78 columns
      local out = { tags_only(line) and vim.trim(line) or (line:gsub('%s+(%*[^%s*]+%*.-)$', '  %1')) }
      local content = not tags_only(line)
      for j = i + 1, math.min(i + MAX_LINES, #lines) do
        local l = lines[j]
        -- Stop at a section rule or at the next entry's tag
        if l:match('^[=-]+$') or (content and l:match('%*[^%s*]+%*%s*$')) then
          break
        end
        if tags_only(l) and l:match('%S') then
          out[#out + 1] = vim.trim(l)
        else
          content = content or l:match('%S') ~= nil
          out[#out + 1] = l
        end
      end
      while #out > 1 and not out[#out]:match('%S') do
        out[#out] = nil
      end
      return out
    end
  end
end

---@param item blink.cmp.CompletionItem
---@return string?, string[]?
function M.lookup(item, type)
  local text = item.textEdit and item.textEdit.newText or item.label
  if not text or text == '' then
    return
  end
  local index = tag_index()
  for _, tag in ipairs(candidates(text, type)) do
    if index[tag] then
      return tag, excerpt(tag, index[tag].path)
    end
  end
end

-- blink's provider override: resolve(source, item, callback)
function M.resolve(source, item, callback)
  if item.documentation then
    return callback(item)
  end
  local ok, _, lines = pcall(M.lookup, item, vim.fn.getcmdcompltype())
  if ok and lines then
    item = vim.deepcopy(item)
    item.documentation = {
      kind = 'plaintext',
      value = table.concat(lines, '\n'),
      -- Drawn as help text: blink's markdown rendering leaves ``` fences in place
      draw = function(opts)
        local buf = opts.window:get_buf()
        local ns = require('blink.cmp.config').appearance.highlight_ns
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        require('blink.cmp.lib.window.docs').highlight_with_treesitter(buf, 'help', 0, #lines)
      end,
    }
  end
  callback(item)
end

return M
