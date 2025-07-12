-- Soothing pastel theme for (Neo)vim
return {
  'catppuccin/nvim',
  lazy = true,
  event = { 'VimEnter', 'ColorschemePre' }, -- Load on startup or colorscheme change
  name = 'catppuccin',
  priority = 1000,
  config = function()
    require('catppuccin').setup({
      flavour = 'mocha',
      term_colors = true, -- Setting for baleia.nvim
      background = { light = 'latte', dark = 'macchiato' },
      custom_highlights = require('catppuccin_highlights').get_custom_highlights,
      integrations = {
        cmp = true,
        treesitter = true,
        colorful_winsep = { enabled = true, color = 'blue' },
        diffview = true,
        fidget = true,
        fzf = true,
        gitsigns = true,
        indent_blankline = {
          enabled = true,
          colored_indent_levels = false,
          scope_color = 'blue',
        },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { 'italic' },
            warnings = { 'italic' },
            hints = { 'italic' },
            information = { 'italic' },
          },
          underlines = {
            errors = { 'undercurl' },
            hints = { 'undercurl' },
            warnings = { 'undercurl' },
            information = { 'undercurl' },
          },
        },
        notify = true,
        symbols_outline = true,
        treesitter_context = true,
      },
    })

    vim.cmd.colorscheme('catppuccin')
  end,
}
