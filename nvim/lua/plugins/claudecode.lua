-- Makes Neovim Claude Code's IDE: Claude sees the current selection and LSP diagnostics, and in its
-- default permission mode shows each edit as a diff here (:w or <Leader>Ca accepts, :q or
-- <Leader>Cd rejects). ws starts Claude in its own tmux window with --ide, so this only runs the
-- server; the neovim skill still covers unsaved buffers, other sessions and quickfix lists.
return {
  'coder/claudecode.nvim',
  -- Claude looks for an IDE when it starts, so the server has to be up early
  event = 'VeryLazy',
  keys = {
    { '<Leader>Cs', '<cmd>ClaudeCodeSend<CR>', mode = 'x', desc = 'Claude: Send selection' },
    { '<Leader>Ca', '<cmd>ClaudeCodeDiffAccept<CR>', desc = 'Claude: Accept proposed edit' },
    { '<Leader>Cd', '<cmd>ClaudeCodeDiffDeny<CR>', desc = 'Claude: Reject proposed edit' },
  },
  opts = {
    terminal = { provider = 'none' },
    track_selection = true,
    diff_opts = { open_in_new_tab = true },
  },
}
