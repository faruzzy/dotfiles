-- fzf-lua open actions: focus an already-open file's window instead of opening it twice
local M = {}

-- Which window each buffer was last displayed in
local buf_last_win = {}

---Start tracking buffer windows. Called from the spec's `init` (startup), so buffers
---visited before fzf-lua first loads are remembered too.
function M.setup()
  local tracker = vim.api.nvim_create_augroup('BufWinTracker', { clear = true })
  vim.api.nvim_create_autocmd('BufWinLeave', {
    group = tracker,
    callback = function(args) buf_last_win[args.buf] = vim.api.nvim_get_current_win() end,
  })
  vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
    group = tracker,
    callback = function(args) buf_last_win[args.buf] = nil end,
  })
end

---Focus an open buffer: its visible window, else the window it was last shown in.
---Deleted (unlisted) buffers don't count, so they reopen in the current window like a new file.
---@return boolean handled
local function switch_to_open_buffer(bufnr)
  if not bufnr or bufnr == -1 or not vim.api.nvim_buf_is_valid(bufnr) or not vim.bo[bufnr].buflisted then
    return false
  end
  local winid = vim.fn.bufwinid(bufnr)
  if winid ~= -1 then
    vim.api.nvim_set_current_win(winid)
    return true
  end
  local last_win = buf_last_win[bufnr]
  if last_win and vim.api.nvim_win_is_valid(last_win) then
    vim.api.nvim_set_current_win(last_win)
    vim.api.nvim_win_set_buf(last_win, bufnr)
    return true
  end
  return false
end

---fzf-lua `files` action
function M.file_switch_or_edit(selected, opts)
  if not selected or not selected[1] then
    return
  end

  local stripped = require('fzf-lua.utils').strip_ansi_coloring(selected[1])
  local fullpath = vim.fn.fnamemodify(stripped:match('^%s*(.-)%s*$'), ':p')
  if switch_to_open_buffer(vim.fn.bufnr(fullpath)) then
    return
  end

  require('fzf-lua.actions').file_edit(selected, opts)
end

---fzf-lua `buffers` action
function M.buf_switch_or_edit(selected, opts)
  if not selected or not selected[1] then
    return
  end

  local stripped = require('fzf-lua.utils').strip_ansi_coloring(selected[1])
  if switch_to_open_buffer(tonumber(stripped:match('%[(%d+)%]'))) then
    return
  end

  require('fzf-lua.actions').buf_edit(selected, opts)
end

function M.switch_or_edit_path(path)
  local fullpath = vim.fn.fnamemodify(path, ':p')
  if switch_to_open_buffer(vim.fn.bufnr(fullpath)) then
    return
  end

  vim.cmd.edit(vim.fn.fnameescape(fullpath))
end

---@return string? path the only file in the cwd, if there is exactly one
function M.single_file_in_cwd()
  local commands = {
    -- Two results are enough to know there isn't exactly one; stop there in big repos
    { 'fd', '--color=never', '--type', 'f', '--type', 'l', '--hidden', '--exclude', '.git', '--exclude', '.jj', '--max-results', '2' },
    { 'rg', '--color=never', '--files', '--hidden', '-g', '!.git', '-g', '!.jj' },
  }

  for _, cmd in ipairs(commands) do
    if vim.fn.executable(cmd[1]) == 1 then
      local files = vim.fn.systemlist(cmd)
      if vim.v.shell_error == 0 and #files == 1 then
        return files[1]
      end
      return nil
    end
  end

  local files = vim.fn.systemlist({ 'find', '.', '-type', 'f', '!', '-path', '*/.git/*', '!', '-path', '*/.jj/*' })
  if vim.v.shell_error == 0 and #files == 1 then
    return files[1]:gsub('^%./', '')
  end
end

---<C-p>: open the only file in the cwd directly, else the files picker
function M.files()
  local single_file = M.single_file_in_cwd()
  if single_file then
    M.switch_or_edit_path(single_file)
    return
  end

  require('fzf-lua').files({
    file_icons = false,
    git_icons = false,
    actions = { ['default'] = M.file_switch_or_edit },
  })
end

---<Leader><CR>
function M.buffers()
  require('fzf-lua').buffers({
    actions = { ['default'] = M.buf_switch_or_edit },
  })
end

return M
