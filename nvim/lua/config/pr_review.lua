-- Review a GitHub PR in diffview without checking out its branch
local M = {}

local function fail(what, res)
  vim.notify(('PRReview: %s failed: %s'):format(what, vim.trim(res.stderr or '')), vim.log.levels.ERROR)
end

---The remote pointing at the PR's repo (origin, or upstream when working from a fork)
---@param repo string owner/name
---@return string?
local function remote_for(repo)
  local out = vim.system({ 'git', 'remote', '-v' }, { text = true }):wait()
  for line in vim.gsplit(out.stdout or '', '\n', { trimempty = true }) do
    local name, url = line:match('^(%S+)%s+(%S+)')
    local slug = url and url:gsub('%.git$', ''):match('[:/]([^/:]+/[^/]+)$')
    if slug and slug:lower() == repo:lower() then return name end
  end
end

---@param number integer|string
function M.open(number)
  number = tostring(number)
  vim.notify('PRReview: fetching #' .. number)
  vim.system(
    { 'gh', 'pr', 'view', number, '--json', 'baseRefName,baseRefOid,headRefOid,url' },
    { text = true },
    vim.schedule_wrap(function(res)
      if res.code ~= 0 then return fail('gh pr view', res) end
      local pr = vim.json.decode(res.stdout)
      local repo = pr.url:match('github%.com/([^/]+/[^/]+)/pull/')
      local remote = remote_for(repo)
      if not remote then
        return vim.notify('PRReview: no git remote points at ' .. repo, vim.log.levels.ERROR)
      end
      -- pull/N/head also covers PRs opened from forks
      vim.system(
        { 'git', 'fetch', '--quiet', remote, pr.baseRefName, ('pull/%s/head'):format(number) },
        { text = true },
        vim.schedule_wrap(function(fetch)
          if fetch.code ~= 0 then return fail('git fetch', fetch) end
          -- three dots diffs from the merge base, which is what GitHub shows
          vim.cmd(('DiffviewOpen %s...%s'):format(pr.baseRefOid, pr.headRefOid))
        end)
      )
    end)
  )
end

---Pick an open PR with fzf-lua, then open it
function M.pick()
  require('fzf-lua').fzf_exec(
    [[gh pr list --limit 100 --json number,title,author,headRefName ]]
      .. [[--jq '.[] | "\(.number)\t\(.title)\t@\(.author.login)\t\(.headRefName)"']],
    {
      prompt = 'PR review> ',
      fzf_opts = { ['--delimiter'] = '\t' },
      preview = 'GH_FORCE_TTY=1 gh pr view {1}',
      actions = {
        ['default'] = function(selected)
          local number = selected[1] and selected[1]:match('^(%d+)')
          if number then M.open(number) end
        end,
      },
    }
  )
end

return M
