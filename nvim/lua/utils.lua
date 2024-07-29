local M = {}

---Create vim highlight
---@param name string
---@param highlight_map vim.api.keyset.highlight
function M.highlight(name, highlight_map)
  vim.api.nvim_set_hl(0, name, highlight_map)
end

return M
