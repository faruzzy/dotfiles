-- Stackable, editable popups for peeking at definitions without leaving your place. A popup is a
-- real buffer: edit and :w it, peek again from inside it (the popups stack), or promote it to a
-- split/tab once it turns into real work. q closes the top popup.

-- - Keys:
--     - gp peeks the definition, next to gd. It replaces Vim's built-in gp (paste and leave the cursor after the text).
--     - <Leader>P + p (peek this spot), u/U (restore the last popup / all popups), c (close all), f (switch focus between popup and window).
--     - <Leader>P + s/v/t/o promotes the popup to a split, a vsplit, a tab, or the current window.
--     - I used <Leader>P because <Leader>p is taken (<Leader>pr opens the GitHub PR).
--   - Multiple definitions (overloads, a .d.ts plus its source) open your fzf picker to choose one. By default overlook would just peek the
--     first.
--   - Popups are real buffers, so you can edit and :w in them, and gp again inside a popup stacks another one.

local function api(fn)
  return function() require('overlook.api')[fn]() end
end

return {
  'WilliamHsieh/overlook.nvim',
  keys = {
    -- Next to gd; replaces Vim's rarely used gp (put and leave the cursor after it)
    { 'gp', api('peek_definition'), desc = 'Peek definition' },
    { '<Leader>Pp', api('peek_cursor'), desc = 'Peek: this spot' },
    { '<Leader>Pu', api('restore_popup'), desc = 'Peek: restore last popup' },
    { '<Leader>PU', api('restore_all_popups'), desc = 'Peek: restore all popups' },
    { '<Leader>Pc', api('close_all'), desc = 'Peek: close all popups' },
    { '<Leader>Pf', api('switch_focus'), desc = 'Peek: switch focus popup/window' },
    { '<Leader>Ps', api('open_in_split'), desc = 'Peek: promote to split' },
    { '<Leader>Pv', api('open_in_vsplit'), desc = 'Peek: promote to vsplit' },
    { '<Leader>Pt', api('open_in_tab'), desc = 'Peek: promote to tab' },
    { '<Leader>Po', api('open_in_original_window'), desc = 'Peek: open in this window' },
  },
  opts = {
    -- Several definitions (overloads, .d.ts + source): pick one in fzf-lua's vim.ui.select
    on_multiple = 'select',
  },
}
