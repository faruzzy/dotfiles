local function get_custom_highlights(colors)
  local utils = require('catppuccin.utils.colors')
  -- This used to reference highlights with require('catppuccin.groups.editor').get()
  -- but that was broken in https://github.com/catppuccin/nvim/issues/664
  -- For details and workaround: https://github.com/catppuccin/nvim/issues/667
  -- Unfortunately the workaround can't be used here
  -- This hard-codes the highlights I was referencing until there's a better solution
  local inc_search = { bg = utils.darken(colors.yellow, 0.90, colors.yellow), fg = colors.mantle }
  local anchor_link = { fg = colors.blue, style = { 'underline' } }
  local inline_code = { bg = colors.surface0 }

  local highlights = {
    -- Default Highlights
    CurSearch = vim.tbl_extend('force', inc_search, { style = { 'bold' } }),
    CursorLineNr = { fg = colors.blue, style = { 'bold' } },

    FoldColumn = { fg = colors.surface1 },
    Folded = { bg = colors.surface0 },
    NormalFloat = { bg = colors.base },
    FloatBorder = { fg = colors.blue, bg = colors.base },
    StatusLine = { fg = colors.text, bg = colors.base },
    TabLine = { fg = colors.text, bg = colors.surface0 },

    -- Custom Highlights
    WinBarDiagnosticError = { fg = colors.red, bg = colors.base },
    WinBarDiagnosticWarn = { fg = colors.yellow, bg = colors.base },
    WinBarDiagnosticHint = { fg = colors.teal, bg = colors.base },
    WinBarDiagnosticInfo = { fg = colors.sky, bg = colors.base },

    -- Treesitter Highlights
    ['@markup.link.label.markdown_inline'] = anchor_link,
    ['@markup.quote'] = { fg = colors.subtext1, style = { 'italic' } },
    ['@markup.raw.markdown_inline'] = inline_code,
    ['@string.special.url'] = anchor_link,

    -- Plugin Highlights
    -- LuaSnip
    LuasnipChoiceNodeActive = { link = 'Visual' },
    LuasnipChoiceNodePassive = { link = 'Visual' },
    LuasnipInsertNodeActive = { link = 'Visual' },
    LuasnipInsertNodePassive = { link = 'Visual' },

    -- fzf-lua
    FzfLuaHeaderBind = { fg = colors.blue },
    FzfLuaHeaderText = { fg = colors.mauve },
    FzfLuaFzfInfo = { fg = colors.mauve },
    FzfLuaFzfMatch = { fg = colors.blue },
    FzfLuaFzfPointer = { fg = colors.blue },
    FzfLuaFzfPrompt = { fg = colors.blue },
    FzfLuaTitle = { link = 'FzfLuaBorder' },

    -- highlight-undo.nvim
    HighlightUndo = { link = 'IncSearch' },
    HighlightRedo = { link = 'IncSearch' },

    -- markdown.nvim
    RenderMarkdownCodeInline = inline_code,

    -- mini.icons
    MiniIconsGrey = { fg = colors.overlay0 },

    -- nvim-cmp
    CmpItemAbbr = { fg = colors.text },
    CmpItemAbbrMatch = { fg = colors.blue },
    CmpItemMenu = { fg = colors.surface2 },

    -- nvim-lightbulb
    LightBulbVirtText = { bg = colors.none },

    -- nvim-treesitter-context
    TreesitterContext = { fg = colors.text, bg = colors.mantle },

    -- LSP Diagnostics
    DiagnosticError = { fg = colors.red },
    DiagnosticWarn = { fg = colors.yellow },
    DiagnosticInfo = { fg = colors.sky },
    DiagnosticHint = { fg = colors.teal },
    DiagnosticVirtualTextError = { fg = colors.red, bg = utils.darken(colors.red, 0.1, colors.base) },
    DiagnosticVirtualTextWarn = { fg = colors.yellow, bg = utils.darken(colors.yellow, 0.1, colors.base) },
    DiagnosticVirtualTextInfo = { fg = colors.sky, bg = utils.darken(colors.sky, 0.1, colors.base) },
    DiagnosticVirtualTextHint = { fg = colors.teal, bg = utils.darken(colors.teal, 0.1, colors.base) },

    LspInlayHint = { fg = colors.overlay0, style = { 'italic' } },

    ['@markup.heading.markdown'] = { fg = colors.mauve, style = { 'bold' } },
    ['@markup.list.markdown'] = { fg = colors.blue },
    ['@markup.strong.markdown'] = { fg = colors.text, style = { 'bold' } },
    ['@markup.italic.markdown'] = { fg = colors.text, style = { 'italic' } },
  }

  return vim.tbl_extend('force', highlights, require('modes').get_initial_highlights(colors))
end

return { get_custom_highlights = get_custom_highlights }
