return {
  'navarasu/onedark.nvim',
  config = function()
    priority = 1000,
    vim.cmd.colorscheme 'onedark'
  end,
  opts = {
    options = {
      icons_enabled = false,
      theme = 'onedark',
      component_separators = '|',
      section_separators = '',
    }
  }
}
