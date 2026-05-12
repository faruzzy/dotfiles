local map = require('utils').map

-- Switch to last buffer
map('n', '<Tab>', '<cmd>b#<cr>', { desc = 'Switch to last buffer' })


-- Line movement (handles wrap)
map('n', 'k', 'v:count == 0 ? \'gk\' : \'k\'', { expr = true, desc = 'Move up with wrap' })
map('n', 'j', 'v:count == 0 ? \'gj\' : \'j\'', { expr = true, desc = 'Move down with wrap' })
map('n', '<A-k>', '<cmd>move .-2<cr>', { desc = 'Move line up' })
map('n', '<A-j>', '<cmd>move .+1<cr>', { desc = 'Move line down' })
map('x', '<A-k>', ':move \'<-2<cr>gv=gv', { desc = 'Move selection up' })
map('x', '<A-j>', ':move \'>+1<cr>gv=gv', { desc = 'Move selection down' })

-- Prevent space key movement
map({ 'n', 'v' }, '<Space>', '<Nop>')

-- Insert mode navigation
map('i', '<c-h>', '<left>')
map('i', '<c-l>', '<right>')

-- Smart quit: close fugitive diff view if active, otherwise save and quit
map('n', '<Leader>x', function()
  local function is_fugitive(buf)
    local name = vim.api.nvim_buf_get_name(buf)
    local ft = vim.bo[buf].filetype
    return name:match('^fugitive://') or name:match('%.git//') or ft == 'fugitive'
  end

  if not is_fugitive(0) then
    vim.cmd('x')
    return
  end

  -- Find the most recently used real file buffer to return to
  local target_buf
  local latest = 0
  for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    local bt = vim.bo[info.bufnr].buftype
    if info.loaded == 1 and bt == '' and info.name ~= '' and not is_fugitive(info.bufnr) then
      if info.lastused > latest then
        latest = info.lastused
        target_buf = info.bufnr
      end
    end
  end

  vim.cmd('diffoff!')

  -- Delete all fugitive-related buffers (status, diff, and .git// index copies)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and is_fugitive(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  vim.cmd('only')
  if target_buf and vim.api.nvim_buf_is_valid(target_buf) then
    vim.api.nvim_set_current_buf(target_buf)
  end
end, { desc = 'Smart quit (close fugitive diff or save+quit)' })
map('n', '<Leader>X', '<cmd>wqa!<cr>', { desc = 'Save all and quit forcefully' })

-- Clear highlighting
map('n', '<Leader>n', '<cmd>noh<cr>', { desc = 'Turn off search highlighting' })

-- Window management
map('n', '<Leader>o', '<cmd>only<cr>', { desc = 'Show only current buffer' })
map('n', '<Leader>O', '<cmd>!open .<cr>', { desc = 'Open current directory in Finder' })

-- Diagnostic navigation
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous Diagnostic' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Next Diagnostic' })
map('n', '<Leader>e', vim.diagnostic.open_float, { desc = 'Open Diagnostic Float' })

-- Diff management
map('n', '<leader>gl', '<cmd>diffget //2<cr>', { desc = 'Get left diff' })
map('n', '<leader>gr', '<cmd>diffget //3<cr>', { desc = 'Get right diff' })

-- Run last command easily (skip special buffers where CR has native meaning)
map({ 'n', 'v' }, '<CR>', function()
  local bt = vim.bo.buftype
  if bt == 'quickfix' or bt == 'help' or bt == 'nofile' or bt == 'prompt' then
    return '<CR>'
  end
  return ':<up>'
end, { expr = true, silent = false, desc = 'Run last command' })

-- Toggle inlay hints
map('n', '<Leader>ti', function()
  local bufnr = 0
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if #clients == 0 then
    vim.notify('No LSP client attached to buffer', vim.log.levels.WARN)
    return
  end
  local inlay_state = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
  local ok, err = pcall(vim.lsp.inlay_hint.enable, not inlay_state, { bufnr = bufnr })
  if not ok then
    vim.notify('Failed to toggle inlay hints: ' .. err, vim.log.levels.ERROR)
  else
    vim.notify('Inlay hints ' .. (not inlay_state and 'enabled' or 'disabled'))
  end
end, { desc = 'Toggle Inlay Hints' })

-- Toggle conceal (hide/show class attribute values)
map('n', '<Leader>tc', function()
  local level = vim.opt_local.conceallevel:get()
  vim.opt_local.conceallevel = level == 0 and 2 or 0
  vim.notify('Conceal ' .. (level == 0 and 'enabled' or 'disabled'))
end, { desc = 'Toggle Conceal' })

-- Undotree toggle
map('n', '<leader>ut', '<cmd>UndotreeToggle<cr>', { desc = 'Toggle Undotree' })

vim.api.nvim_create_user_command(
  'Stash',
  function(opts) vim.cmd('Git stash push -m ' .. vim.fn.shellescape(opts.args)) end,
  { nargs = 1 }
)

-- Helper function to prompt for changed buffers using vim.ui.input
-- This function now directly uses the :Bdelete command from vim-bbye
local function prompt_and_delete_changed_buffer(buf, callback)
  vim.ui.input({ prompt = 'Buffer ' .. buf.name .. ' has changes. Close anyway? (y/n): ' }, function(input)
    if input == 'y' or input == 'Y' then vim.cmd('silent! Bdelete! ' .. buf.bufnr) end
    callback()
  end)
end

-- Close all other buffers
function CloseAllButCurrent()
  local current_buf = vim.fn.bufnr()
  local bufs_to_process = {}

  local all_listed_bufs = vim.fn.getbufinfo({ buflisted = 1 })
  for _, buf in ipairs(all_listed_bufs) do
    if buf.bufnr ~= current_buf then table.insert(bufs_to_process, buf) end
  end

  local i = 1
  local function process_next_buffer()
    if i <= #bufs_to_process then
      local buf = bufs_to_process[i]
      if buf.changed == 1 then
        prompt_and_delete_changed_buffer(buf, function()
          i = i + 1
          process_next_buffer()
        end)
      else
        vim.cmd('silent! Bdelete ' .. buf.bufnr)
        i = i + 1
        process_next_buffer()
      end
    else
      vim.cmd('only')
      local current_win_id = vim.fn.bufwinid(current_buf)
      if current_win_id ~= -1 then
        vim.fn.win_gotoid(current_win_id)
      else
        vim.cmd('normal! <C-w>h')
      end
    end
  end

  process_next_buffer()
end

map('n', '<Leader>aq', function() CloseAllButCurrent() end, { desc = 'Close all other buffers' })

-- Open GitHub Pull Request for current branch
local function github_pull_request()
  local file_dir = vim.fn.expand('%:p:h')
  if file_dir == '' then
    vim.notify('Current buffer has no file path', vim.log.levels.ERROR)
    return
  end

  local remotes = vim.fn.system('git -C ' .. vim.fn.shellescape(file_dir) .. ' remote -v')
  if vim.v.shell_error ~= 0 then
    vim.notify('Not a git repository', vim.log.levels.ERROR)
    return
  end

  local branch =
    vim.fn.system('git -C ' .. vim.fn.shellescape(file_dir) .. ' symbolic-ref --short -q HEAD'):gsub('[\r\n]', '')
  if vim.v.shell_error ~= 0 then
    vim.notify('Could not determine current branch', vim.log.levels.ERROR)
    return
  end

  local domain, repo
  if remotes:find('https') then
    domain = remotes:match('https://([^/]+)/')
    repo = remotes:match('https://[^/]+/([^%s]+)')
  else
    domain = remotes:match('@([^:/]+)[:/]')
    repo = remotes:match('@[^:/]+[:/]([^%s]+)')
  end

  if repo then repo = repo:gsub('%.git$', '') end

  if not domain or not repo or domain == '' or repo == '' then
    vim.notify('Could not determine Git repo name for current file!', vim.log.levels.ERROR)
    return
  end

  local url = ('https://%s/%s/compare/%s?expand=1'):format(domain, repo, branch)
  vim.fn.system('open ' .. vim.fn.shellescape(url))
  if vim.v.shell_error ~= 0 then vim.notify('Failed to open URL: ' .. url, vim.log.levels.ERROR) end
end

vim.api.nvim_create_user_command('PR', github_pull_request, {})
map('n', '<leader>pr', github_pull_request, { desc = 'Open GitHub Pull Request' })

-- Google search
local function goog(pat, lucky)
  local q = '"'
    .. pat:gsub('["\n]', ' '):gsub('[%p ]', function(c) return string.format('%%%02X', string.byte(c)) end)
    .. '"'
  local url = 'https://www.google.com/search?' .. (lucky and 'btnI&' or '') .. 'q=' .. q
  vim.fn.system('open ' .. vim.fn.shellescape(url))
  if vim.v.shell_error ~= 0 then vim.notify('Failed to open Google Search', vim.log.levels.ERROR) end
end
map('n', '<leader>?', function() goog(vim.fn.expand('<cWORD>'), false) end, { desc = 'Google Search' })
map('n', '<leader>!', function() goog(vim.fn.expand('<cWORD>'), true) end, { desc = 'Google Lucky Search' })
map('x', '<leader>?', function()
  vim.cmd('noautocmd normal! "gy')
  goog(vim.fn.getreg('g'), false)
end, { desc = 'Google Search Selection' })
map('x', '<leader>!', function()
  vim.cmd('noautocmd normal! "gy')
  goog(vim.fn.getreg('g'), true)
end, { desc = 'Google Lucky Search Selection' })

map('n', '<leader>wf', function()
  local wins = vim.api.nvim_list_wins()
  for _, win in ipairs(wins) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= '' then -- it's a floating window
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  print('No floating window found')
end, { desc = 'Jump to floating window' })

-- Compile and run
local compile_run_buf = nil
local function compile_and_run()
  local ok, err = pcall(vim.cmd, 'w')
  if not ok then
    vim.notify('Failed to save file: ' .. err, vim.log.levels.ERROR)
    return
  end

  if compile_run_buf and vim.api.nvim_buf_is_valid(compile_run_buf) then
    vim.api.nvim_buf_delete(compile_run_buf, { force = true })
  end

  local ft = vim.bo.filetype
  local file = vim.fn.shellescape(vim.fn.expand('%'))
  local base = vim.fn.shellescape(vim.fn.expand('%:r'))
  local cmd
  if ft == 'c' then
    cmd = 'gcc ' .. file .. ' -o ' .. base .. ' && ./' .. base
  elseif ft == 'java' then
    cmd = 'javac ' .. file .. ' && java ' .. base
  elseif ft == 'javascript' then
    cmd = 'node ' .. file
  elseif ft == 'sh' then
    cmd = 'bash ' .. file
  elseif ft == 'python' then
    cmd = 'python ' .. file
  elseif ft == 'typescript' then
    cmd = 'npx tsx ' .. file
  elseif ft == 'lua' then
    cmd = 'lua ' .. file
  end
  if cmd then
    vim.cmd('split | terminal ' .. cmd)
    compile_run_buf = vim.api.nvim_get_current_buf()
  end
end
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'java', 'javascript', 'typescript', 'sh', 'python', 'lua' },
  callback = function() map('n', '<leader>c', compile_and_run, { buffer = true, desc = 'Compile and Run' }) end,
})

-- Copy commands
local function copy_to_clipboard(cmd)
  local result = vim.fn.expand(cmd)
  vim.fn.setreg('*', result)
  print('Copied to clipboard: ' .. result)
end
vim.api.nvim_create_user_command('CopyFilename', function() copy_to_clipboard('%:t') end, {})
vim.api.nvim_create_user_command('CopyPath', function() copy_to_clipboard('%:h') end, {})
vim.api.nvim_create_user_command('CopyAbsolutePath', function() copy_to_clipboard('%:p:h') end, {})
vim.api.nvim_create_user_command('CopyFilepath', function() copy_to_clipboard('%') end, {})
vim.api.nvim_create_user_command('CopyAbsoluteFilepath', function() copy_to_clipboard('%:p') end, {})
map('n', '<leader>yfn', '<cmd>CopyFilename<cr>', { desc = 'Copy Filename' })
map('x', '<leader>yfn', '<cmd>CopyFilename<cr>', { desc = 'Copy Filename' })
map('n', '<leader>yp', '<cmd>CopyPath<cr>', { desc = 'Copy Path' })
map('x', '<leader>yp', '<cmd>CopyPath<cr>', { desc = 'Copy Path' })
map('n', '<leader>yap', '<cmd>CopyAbsolutePath<cr>', { desc = 'Copy Absolute Path' })
map('x', '<leader>yap', '<cmd>CopyAbsolutePath<cr>', { desc = 'Copy Absolute Path' })
map('n', '<leader>yfp', '<cmd>CopyFilepath<cr>', { desc = 'Copy Filepath' })
map('x', '<leader>yfp', '<cmd>CopyFilepath<cr>', { desc = 'Copy Filepath' })
map('n', '<leader>yafp', '<cmd>CopyAbsoluteFilepath<cr>', { desc = 'Copy Absolute Filepath' })
map('x', '<leader>yafp', '<cmd>CopyAbsoluteFilepath<cr>', { desc = 'Copy Absolute Filepath' })
