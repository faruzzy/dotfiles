---@type LspServer
return {
	display = "emmet-language-server",
	config = function(config)
		config.filetypes = {
			'css',
			'html',
			'javascriptreact',
			'less',
			'sass',
			'scss',
			'typescriptreact',
		}
		return config
	end,
}
