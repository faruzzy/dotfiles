local M = {}

---Create augroup
---@param group_name string
---@param autocmds any
function M.augroup(group_name, autocmds)
  local group = vim.api.nvim_create_augroup('my_' .. group_name, {})

  for _, autocmd in ipairs(autocmds) do
    local event = autocmd[1]
    local opts = vim.tbl_extend('force', { group = group }, autocmd[2])

    vim.api.nvim_create_autocmd(event, opts)
  end
end

return M
