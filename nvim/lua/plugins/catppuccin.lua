-- Soothing pastel theme for (Neo)vim
return {
  'catppuccin/nvim',
  -- Load before other plugins: lualine's 'auto' theme reads the highlights when it is set up
  lazy = false,
  name = 'catppuccin',
  priority = 1000,
  config = function()
    require('catppuccin').setup({
      flavour = 'mocha',
      term_colors = true,
      custom_highlights = require('catppuccin_highlights').get_custom_highlights,
      -- Hints have no underline (catppuccin_highlights.lua)
      lsp_styles = {
        underlines = {
          errors = { 'undercurl' },
          warnings = { 'undercurl' },
          information = { 'undercurl' },
        },
      },
      -- The rest are detected from the installed plugins; diffview-plus.nvim isn't
      integrations = {
        diffview = true,
        indent_blankline = { scope_color = 'blue' },
      },
    })

    vim.cmd.colorscheme('catppuccin')
  end,
}
