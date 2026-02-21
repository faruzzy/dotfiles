---@type LazySpec
return {
  { 'Bilal2453/luvit-meta', lazy = true },
  ---@module 'lazydev'
  ---@type lazydev.Config
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        'lazy.nvim',
        'luvit-meta/library/uv.lua',
        'catppuccin',
        'nvim-lspconfig',
        'mini.icons',
      },
    },
  },
}
