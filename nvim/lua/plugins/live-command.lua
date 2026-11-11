-- Live preview for :norm and :g, like inc-rename for renames: each affected line shows the
-- result as you type, with insertions, changes and deletions highlighted. :Preview <cmd> does
-- the same for any other command.
return {
  'smjonas/live-command.nvim',
  main = 'live-command',
  -- Not cmd: lazy's stand-in commands have no preview, so the first :Norm wouldn't preview
  event = 'CmdlineEnter',
  opts = {
    commands = {
      Norm = { cmd = 'norm' },
      G = { cmd = 'g' },
    },
  },
  init = function()
    -- Keep typing :norm and :g; they become the previewing commands. Only at the start of a
    -- : command (after a range like '<,'> or %), and not for norm! / g!, which these can't take
    local function alias(from, to)
      vim.keymap.set('ca', from, function()
        local line = vim.fn.getcmdline()
        local at_start = line:match("^[%%%d,.$'<>+-]*" .. from .. '$') ~= nil
        return (vim.fn.getcmdtype() == ':' and at_start and vim.v.char ~= '!') and to or from
      end, { expr = true, desc = ':' .. from .. ' with live preview' })
    end
    alias('norm', 'Norm')
    alias('normal', 'Norm')
    alias('g', 'G')
  end,
}
