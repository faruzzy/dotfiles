-- fzf-lua git pickers
local M = {}

---git_commits / git_bcommits without merge commits by default; alt-m reopens with them toggled
---@param picker 'commits'|'bcommits'
---@param show_merges? boolean
function M.log_picker(picker, show_merges)
  local cmd = require('fzf-lua.defaults').defaults.git[picker].cmd
  if not show_merges then cmd = cmd:gsub('^git log ', 'git log --no-merges ') end
  require('fzf-lua')['git_' .. picker]({
    cmd = cmd,
    prompt = (picker == 'commits' and 'Commits' or 'Buffer commits') .. (show_merges and '> ' or ' (no merges)> '),
    -- A custom header replaces fzf-lua's action hints, so list the keys here
    header = (show_merges and 'alt-m: hide merges' or 'alt-m: show merges')
      .. ' ╱ alt-r: toggle sort (best match ↔ history) ╱ ctrl-d: diff ╱ ctrl-y: copy hash',
    keymap = { fzf = { ['alt-r'] = 'toggle-sort' } },
    actions = {
      ['alt-m'] = {
        fn = function() M.log_picker(picker, not show_merges) end,
        header = show_merges and 'hide merges' or 'show merges',
      },
    },
  })
end

return M
