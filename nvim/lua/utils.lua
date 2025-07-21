local M = {}

---@alias map_fn fun(mode: string | table<string>, lhs: string, rhs: string | function, opts?: table)

---Define vim keymap
---@type map_fn
function M.map(mode, lhs, rhs, opts)
  local options = { silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

---Define vim keymap for buffer
---@param bufnr number | boolean
---@return map_fn
function M.buffer_map(bufnr)
  return function(mode, lhs, rhs, opts)
    local options = { buffer = bufnr }
    if opts then
      options = vim.tbl_extend('force', options, opts)
    end
    M.map(mode, lhs, rhs, options)
  end
end

---Maps from a table to list
---@generic K : string
---@generic V
---@generic R
---@param fn fun(value: V, key: K): R
---@param tbl table<K, V>
---@return R[]
function M.map_table_to_list(fn, tbl)
  local list = {}

  for key, value in pairs(tbl) do
    table.insert(list, fn(value, key))
  end

  return list
end

---Get the current snippet engine
---@return 'nvim' | 'luasnip'
function M.get_snippet_engine()
  return 'luasnip'
end

---Create vim highlight
---@param name string
---@param highlight_map vim.api.keyset.highlight
function M.highlight(name, highlight_map)
  vim.api.nvim_set_hl(0, name, highlight_map)
end

---@class AutoCmdCallbackArgs
---@field id number
---@field event string
---@field group number | nil
---@field match string
---@field buf number
---@field file string
---@field data any

---@class AutoCmd
---@field [1] string | string[]
---@field pattern? string | string[]
---@field buffer? number
---@field desc? string
---@field callback? fun(args: AutoCmdCallbackArgs) | string
---@field command? string
---@field once? boolean
---@field nested? boolean

---Create augroup
---@param group_name string
---@param autocmds AutoCmd[]
function M.augroup(group_name, autocmds)
  local group = vim.api.nvim_create_augroup('my_' .. group_name, {})

  for _, autocmd in ipairs(autocmds) do
    local event = autocmd[1]
    local opts = vim.tbl_extend('force', { group = group }, autocmd)
    table.remove(opts, 1)

    vim.api.nvim_create_autocmd(event, opts)
  end
end

function M.is_git_repo()
  local is_repo = vim.fn.system('git rev-parse --is-inside-work-tree')
  return vim.v.shell_error == 0
end

function M.find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print('Not a git repository. Searching on current working directory')
    return cwd
  end
  return git_root
end

---Define vim user command
---@param name string
---@param command string | function
---@param opts? vim.api.keyset.user_command
function M.user_command(name, command, opts)
  local options = { force = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_create_user_command(name, command, options)
end

---Filter key-value table based on key
---@param table table<string, any>
---@param keys string[]
---@return table<string, any>
function M.filter_table_by_keys(table, keys)
  local rv = {}
  for _, key in ipairs(keys) do
    rv[key] = table[key]
  end
  return rv
end

return M
