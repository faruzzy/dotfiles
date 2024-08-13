local M = {}

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

return M
