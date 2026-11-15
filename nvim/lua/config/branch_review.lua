-- Branch review: gitsigns compares every buffer against where the branch left the default branch
-- (its merge-base), so ]c/[c and <Leader>hp walk everything the branch changed while you stay in
-- the real files with LSP; the changed files go to quickfix. Toggle again for the last commit.
local M = {}

local function git(args, cwd)
  local result = vim.system(vim.list_extend({ 'git' }, args), { cwd = cwd, text = true }):wait()
  return result.code == 0 and vim.trim(result.stdout) or nil
end

local function default_branch(root)
  local head = git({ 'rev-parse', '--abbrev-ref', 'origin/HEAD' }, root)
  if head and head ~= 'origin/HEAD' then
    return head
  end
  for _, candidate in ipairs({ 'origin/main', 'origin/master', 'main', 'master' }) do
    if git({ 'rev-parse', '--verify', '--quiet', candidate }, root) then
      return candidate
    end
  end
end

function M.toggle()
  local gitsigns = require('gitsigns')

  -- gitsigns keeps the base it compares against; it's set only while a review is on
  if require('gitsigns.config').config.base then
    gitsigns.reset_base(true)
    vim.notify('Branch review off: signs compare against the last commit')
    return
  end

  local dir = vim.fn.expand('%:p:h')
  local root = git({ 'rev-parse', '--show-toplevel' }, vim.fn.isdirectory(dir) == 1 and dir or nil)
  if not root then
    vim.notify('Branch review: not in a git repository', vim.log.levels.WARN)
    return
  end
  local default = default_branch(root)
  local base = default and git({ 'merge-base', 'HEAD', default }, root)
  if not base then
    vim.notify('Branch review: no default branch to compare against', vim.log.levels.WARN)
    return
  end

  -- Against the working tree, so uncommitted changes are listed too
  local items = {}
  for _, line in ipairs(vim.split(git({ 'diff', '--name-status', base }, root) or '', '\n', { trimempty = true })) do
    local fields = vim.split(line, '\t')
    -- Renames list the old and new path; the new one is the file to open
    table.insert(items, { filename = root .. '/' .. fields[#fields], lnum = 1, text = fields[1] })
  end
  if #items == 0 then
    vim.notify(('Branch review: nothing changed since %s'):format(default))
    return
  end

  gitsigns.change_base(base, true)
  vim.fn.setqflist({}, ' ', { title = 'Branch changes since ' .. default, items = items })
  vim.cmd('botright copen')
  vim.notify(('Branch review: %d files changed since %s (<leader>hB to stop)'):format(#items, default))
end

return M
