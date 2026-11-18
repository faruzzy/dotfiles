-- Briefly highlights the text changed by undo/redo, search, comment, yank and paste.
-- Yank is hooked in faruzzy/autocmd.lua and paste in plugins/editing.lua (nvim-pasta keeps its
-- context-aware paste; undo-glow's own paste_below/above would replace it with a plain `p`).
---@type LazySpec
return {
  'y3owk1n/undo-glow.nvim',
  version = '*',
  keys = {
    { 'u', function() require('undo-glow').undo() end, desc = 'Undo' },
    { '<C-r>', function() require('undo-glow').redo() end, desc = 'Redo' },
    { 'n', function() require('undo-glow').search_next() end, desc = 'Next search match' },
    { 'N', function() require('undo-glow').search_prev() end, desc = 'Previous search match' },
    { '*', function() require('undo-glow').search_star() end, desc = 'Search word forward' },
    { '#', function() require('undo-glow').search_hash() end, desc = 'Search word backward' },
    {
      'gc',
      function()
        -- The comment operator moves the cursor to the start of the motion; put it back.
        local pos = vim.fn.getpos('.')
        vim.schedule(function() vim.fn.setpos('.', pos) end)
        return require('undo-glow').comment()
      end,
      mode = { 'n', 'x' },
      expr = true,
      desc = 'Toggle comment',
    },
    { 'gcc', function() return require('undo-glow').comment_line() end, expr = true, desc = 'Toggle comment line' },
  },
  opts = function()
    -- Catppuccin loads eagerly, so its palette is available here; the defaults are Dracula colours.
    local c = require('catppuccin.palettes').get_palette()
    return {
      animation = { enabled = true, duration = 300 },
      highlights = {
        undo = { hl = 'UgUndo', hl_color = { bg = c.red } },
        redo = { hl = 'UgRedo', hl_color = { bg = c.green } },
        yank = { hl = 'UgYank', hl_color = { bg = c.yellow } },
        paste = { hl = 'UgPaste', hl_color = { bg = c.sky } },
        search = { hl = 'UgSearch', hl_color = { bg = c.mauve } },
        comment = { hl = 'UgComment', hl_color = { bg = c.peach } },
        cursor = { hl = 'UgCursor', hl_color = { bg = c.pink } },
      },
    }
  end,
}
