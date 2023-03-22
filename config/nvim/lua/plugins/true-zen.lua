local M = {
	"Pocco81/true-zen.nvim",
	config = function()
		 require("true-zen").setup {
			-- your config goes here
			-- or just leave it empty :)
		 }
	end,
}

function M.config()
	local truezen = require('true-zen')
	vim.keymap.set('n', '<leader>za', truezen.ataraxis, { noremap = true })
end

return M
