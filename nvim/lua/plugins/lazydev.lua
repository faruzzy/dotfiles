-- Neovim/plugin types for lua_ls. Adds $VIMRUNTIME and any required plugin to the
-- workspace library on demand, so lua_ls.lua doesn't list libraries itself.
---@type LazySpec
return {
  ---@module 'lazydev'
  ---@type lazydev.Config
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        'lazy.nvim',
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        'catppuccin',
        'mason.nvim',
        'mini.icons',
      },
    },
  },
}
