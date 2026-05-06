return {
  'jinh0/eyeliner.nvim',
  config = function()
    require('eyeliner').setup({
      highlight_on_key = true,
      dim = false,
    })

    local colors = require('colors').get_colors()

    require('utils').highlight('EyelinerPrimary', {
      fg = colors.sapphire,
      bold = true,
      underline = true,
    })
    require('utils').highlight('EyelinerSecondary', {
      fg = colors.pink,
      underline = true,
    })
  end,
}
