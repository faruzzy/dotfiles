-- fast and fully programmable greeter for neovim
return {
  'goolord/alpha-nvim',
  requires = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('alpha').setup(require('alpha.themes.startify').config)
  end,
}
