local config_catpuccin = function()
  require('catppuccin').setup({
    flavour = 'frappe',
    term_colors = true,
    background = {
      light = 'latte',
      dark  = 'macchiato',
    },
    dim_inactive = {
      enabled     = false,
      shade       = 'dark',
      perccentage = 0.15,
    },
    styles = {
      comments    = { 'italic' },
      conditional = { 'italic' },
      functions   = { 'bold', 'italic' },
      keywords    = { 'bold' },
      strings     = {},
      variables   = {},
    },
    integrations = {
      aerial             = true,
      cmp                = true,
      gitsigns           = true,
      leap               = true,
      lsp_trouble        = true,
      markdown           = true,
      mason              = true,
      noice              = true,
      notify             = true,
      nvimtree           = true,
      symbols_outline    = true,
      telescope          = true,
      treesitter         = true,
      treesitter_context = true,
      ts_rainbow         = true,
      which_key          = true,
    },
    -- Special integrations, see https://github.com/catppuccin/nvim#special-integrations
    dap = {
      enabled   = true,
      enable_ui = true,
    },
    indent_blankline = {
      enabled = true,
      colored_indent_levels = true,
    },
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors      = { 'italic' },
        hints       = { 'italic' },
        warnings    = { 'italic' },
        information = { 'italic' },
      },
      underlines = {
        errors      = { 'underline' },
        hints       = { 'underline' },
        warnings    = { 'underline' },
        information = { 'underline' },
      },
    },
  })
  vim.cmd.colorscheme "catppuccin"
end

return {
  'catppuccin/nvim',
  name = 'catppuccin',
  config = config_catpuccin
  -- config = function()
  --   vim.cmd.colorscheme "catppuccin-frappe"
  -- end
}
