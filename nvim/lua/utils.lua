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
	local group = vim.api.nvim_create_augroup("my_" .. group_name, {})

	for _, autocmd in ipairs(autocmds) do
		local event = autocmd[1]
		local opts = vim.tbl_extend("force", { group = group }, autocmd)
		table.remove(opts, 1)

		vim.api.nvim_create_autocmd(event, opts)
	end
end

---Define vim user command
---@param name string
---@param command string | function
---@param opts? vim.api.keyset.user_command
function M.user_command(name, command, opts)
	local options = { force = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
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
