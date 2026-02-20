---@type LspServer
return {
	display = "emmet-ls",
	config = function(config)
		config.init_options = {
			includeLanguages = {
				javascriptreact = 'html',
			},
		}
		return config
	end,
}
