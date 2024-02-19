return {
  'catppuccin/nvim',
  name = 'catppuccin',
  config = function ()
    require('catppuccin').setup({
      flavour = 'frappe',
      term_colors = true,
      background = {
        light = 'latte',
        dark  = 'macchiato',
      },
      custom_highlights = function(colors)
        local editor_highlights = require('catppuccin.groups.editor').get()

        local telescope_selection = vim.tbl_extend('force', editor_highlights.CursorLine, {
          fg = colors.blue,
        })

        return {
          -- Default Highlights
          CurSearch = vim.tbl_extend('force', editor_highlights.IncSearch, {
            style = { 'bold' },
          }),
          CursorLineNr = {
            fg = colors.blue,
            bg = editor_highlights.CursorLine.bg,
            style = { 'bold' },
          },
          Folded = { fg = colors.blue, bg = colors.surface0 },
          NormalFloat = { bg = colors.base },
          StatusLine = { fg = colors.text, bg = colors.base },
          TabLine = { fg = colors.text, bg = colors.surface0 },
          TabLineSep = { fg = colors.surface0, bg = colors.base },
          WinBarDiagnosticError = { fg = colors.red, bg = colors.base },
          WinBarDiagnosticWarn = { fg = colors.yellow, bg = colors.base },
          WinBarDiagnosticHint = { fg = colors.teal, bg = colors.base },
          WinBarDiagnosticInfo = { fg = colors.sky, bg = colors.base },

          -- Plugin Highlights
          -- highlight-undo.nvim
          HighlightUndo = { link = 'IncSearch' },

          -- nvim-hlslens
          HlSearchLens = editor_highlights.Search,

          -- nvim-lightbulb
          LightBulbVirtText = { bg = colors.none },

          -- nvim-tree.lua
          NvimTreeExecFile = { style = { 'underline', 'bold' } },
          NvimTreeNormal = { fg = colors.text, bg = colors.base },
          NvimTreeWinSeparator = { fg = colors.surface1, bg = colors.none },

          -- nvim-treesitter-context
          TreesitterContext = { fg = colors.text, bg = colors.mantle },

          -- quick-scope
          QuickScopePrimary = { fg = colors.sapphire, style = { 'underline', 'bold' } },
          QuickScopeSecondary = { fg = colors.pink, style = { 'underline' } },

          -- telescope.lua
          TelescopePromptPrefix = { fg = colors.blue },
          TelescopeResultsDiffAdd = { fg = colors.green },
          TelescopeResultsDiffChange = { fg = colors.yellow },
          TelescopeResultsDiffDelete = { fg = colors.red },
          TelescopeResultsDiffUntracked = { fg = colors.none },
          TelescopeSelection = telescope_selection,
          TelescopeSelectionCaret = telescope_selection,
        }
      end,
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
}
