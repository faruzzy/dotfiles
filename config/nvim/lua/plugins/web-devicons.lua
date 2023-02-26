local M = { 'nvim-tree/nvim-web-devicons' }

function M.config()
  local web_devicons = require('nvim-web-devicons')

  web_devicons.setup()
end

return M
