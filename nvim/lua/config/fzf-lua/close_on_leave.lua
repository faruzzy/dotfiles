-- Close an open fzf-lua picker when focus moves to a regular window (e.g. a mouse click on a
-- buffer), like pressing Esc. Without this the picker stays open behind and Esc goes to the buffer.
local M = {}

function M.setup()
  vim.api.nvim_create_autocmd('WinEnter', {
    group = vim.api.nvim_create_augroup('fzf_lua_close_on_leave', { clear = true }),
    callback = function()
      if not package.loaded['fzf-lua'] then
        return
      end
      local picker = require('fzf-lua').win.__SELF()
      if not picker or picker:hidden() or not picker.fzf_winid or not vim.api.nvim_win_is_valid(picker.fzf_winid) then
        return
      end
      local win = vim.api.nvim_get_current_win()
      -- The picker itself, its preview and borders are floats; only leaving for a normal window closes it
      if win == picker.fzf_winid or vim.api.nvim_win_get_config(win).relative ~= '' then
        return
      end
      -- Send fzf an Esc rather than closing the window: closing kills fzf before fzf-lua saves the
      -- query, so <C-g> (resume) would come back empty
      local chan = picker.fzf_bufnr and vim.api.nvim_buf_is_valid(picker.fzf_bufnr) and vim.bo[picker.fzf_bufnr].channel
      if chan and chan > 0 then
        vim.api.nvim_chan_send(chan, '\27')
      end
    end,
  })
end

return M
