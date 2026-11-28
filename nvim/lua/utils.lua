local M = {}

---Define vim keymap
---@param mode string | table<string>
---@param lhs string
---@param rhs string | function
---@param opts? table
function M.map(mode, lhs, rhs, opts)
  local options = { silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

---Define vim keymap for buffer
---@param bufnr number | boolean
---@return fun(mode: string | table<string>, lhs: string, rhs: string | function, opts?: table)
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

---Create vim highlight
---@param name string
---@param highlight_map vim.api.keyset.highlight
function M.highlight(name, highlight_map) vim.api.nvim_set_hl(0, name, highlight_map) end

---@class AutoCmd: vim.api.keyset.create_autocmd
---@field [1] vim.api.keyset.events | vim.api.keyset.events[]

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

-- Filetypes whose class attribute values after/queries conceal
local class_conceal_filetypes = { html = true, javascript = true, javascriptreact = true, typescriptreact = true }

---Show class values unless the buffer opted to hide them (<Leader>tc); conceallevel is per window,
---so restore the global value when the window moves on to another filetype
function M.apply_class_conceal(buf)
  if class_conceal_filetypes[vim.bo[buf].filetype] then
    vim.opt_local.conceallevel = vim.b[buf].hide_classes and 2 or 0
    vim.w.class_conceal_set = true
  elseif vim.w.class_conceal_set then
    vim.opt_local.conceallevel = vim.go.conceallevel
    vim.w.class_conceal_set = nil
  end
end

---@return boolean handled false when the buffer isn't a class-concealing filetype
function M.toggle_class_conceal(buf)
  if not class_conceal_filetypes[vim.bo[buf].filetype] then return false end
  vim.b[buf].hide_classes = not vim.b[buf].hide_classes
  M.apply_class_conceal(buf)
  return true
end

return M
