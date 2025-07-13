local opts = { silent = true, noremap = true }

-- Buffer navigation
vim.keymap.set('n', ']b', vim.cmd.bnext, opts)    -- Next buffer
vim.keymap.set('n', '[b', vim.cmd.bprev, opts)    -- Previous buffer
vim.keymap.set('n', '<Tab>', '<cmd>b#<cr>', opts) -- Switch to last buffer

-- AutoSave toggle
vim.api.nvim_set_keymap('n', '<leader>as', ':ASToggle<CR>', opts) -- Toggle AutoSave

-- Line movement (handles wrap)
vim.keymap.set('n', 'k', 'v:count == 0 ? \'gk\' : \'k\'', { expr = true, silent = true }) -- Move up with wrap
vim.keymap.set('n', 'j', 'v:count == 0 ? \'gj\' : \'j\'', { expr = true, silent = true }) -- Move down with wrap
vim.keymap.set('n', '<A-k>', '<CMD>move .-2<CR>', opts)                                   -- Move line up (NORMAL)
vim.keymap.set('n', '<A-j>', '<CMD>move .+1<CR>', opts)                                   -- Move line down (NORMAL)
vim.keymap.set('x', '<A-k>', ':move \'<-2<CR>gv=gv', opts)                                -- Move line up (VISUAL)
vim.keymap.set('x', '<A-j>', ':move \'>+1<CR>gv=gv', opts)                                -- Move line down (VISUAL)

-- Prevent space key movement
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', opts) -- Disable space navigation

-- Insert mode navigation
vim.keymap.set('i', '<c-h>', '<left>', opts)  -- Move left
vim.keymap.set('i', '<c-l>', '<right>', opts) -- Move right

-- Save and quit
vim.keymap.set('n', '<Leader>x', ':x<CR>', opts)    -- Save and quit
vim.keymap.set('n', '<Leader>X', ':wqa!<CR>', opts) -- Save all and quit forcefully

-- Clear highlighting
vim.keymap.set('n', '<Leader>n', ':noh<cr>', opts) -- Turn off search highlighting

-- Window management
vim.keymap.set('n', '<Leader>o', ':only<cr>', opts)    -- Show only current buffer
vim.keymap.set('n', '<Leader>O', ':!open .<cr>', opts) -- Open current directory in Finder

-- Diagnostic navigation
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous Diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next Diagnostic' })
vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float, { desc = 'Open Diagnostic Float' })

-- LSP actions
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'LSP Hover Documentation' })
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'LSP Go to Definition' })
vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, { desc = 'Buffer Rename' })
vim.keymap.set('n', '<Leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action' })

-- Diff management
vim.keymap.set('n', '<leader>gl', '<cmd>diffget //2<cr>', opts) -- Get left diff
vim.keymap.set('n', '<leader>gr', '<cmd>diffget //3<cr>', opts) -- Get right diff

-- Run last command
local def_opts = { silent = false, noremap = true }
vim.keymap.set({ 'n', 'v' }, '<CR>', ':<up>', def_opts) -- Repeat last command

-- Toggle inlay hints
vim.keymap.set('n', '<Leader>ti', function()
  local bufnr = 0
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
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

-- Undotree toggle
vim.keymap.set('n', '<leader>ut', vim.cmd.UndotreeToggle, opts) -- Toggle Undotree

-- Close all other buffers
function CloseAllButCurrent()
  local current_buf = vim.fn.bufnr()
  local current_win = vim.fn.win_getid()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  for _, buf in ipairs(bufs) do
    if buf.bufnr ~= current_buf and buf.changed == 1 then
      vim.ui.input({ prompt = 'Buffer ' .. buf.name .. ' has changes. Close anyway? (y/n): ' }, function(input)
        if input == 'y' or input == 'Y' then
          vim.cmd('silent! Bdelete ' .. buf.bufnr)
        end
      end)
      return -- Wait for user input
    elseif buf.bufnr ~= current_buf then
      vim.cmd('silent! Bdelete ' .. buf.bufnr)
    end
  end
  vim.fn.win_gotoid(current_win)
end

vim.keymap.set('n', '<Leader>aq', function()
  CloseAllButCurrent()
end, { silent = true, desc = 'Close all other buffers except current one.' })

-- Delete current buffer
vim.keymap.set('n', '<Leader>q', ':Bdelete<CR>', opts)

-- Google search
local function goog(pat, lucky)
  local q = '"'
      .. pat:gsub('["\n]', ' '):gsub('[%p ]', function(c)
        return string.format('%%%02X', string.byte(c))
      end)
      .. '"'
  local url = 'https://www.google.com/search?' .. (lucky and 'btnI&' or '') .. 'q=' .. q
  vim.fn.system('open "' .. url .. '"')
end
vim.keymap.set('n', '<leader>?', function()
  goog(vim.fn.expand('<cWORD>'), false)
end, { silent = true, desc = 'Google Search' })
vim.keymap.set('n', '<leader>!', function()
  goog(vim.fn.expand('<cWORD>'), true)
end, { silent = true, desc = 'Google Lucky Search' })
vim.keymap.set(
  'x',
  '<leader>?',
  [[:<C-u>lua goog(vim.fn.getreg('g'), false)<CR>gv]],
  { silent = true, desc = 'Google Search Selection' }
)
vim.keymap.set(
  'x',
  '<leader>!',
  [[:<C-u>lua goog(vim.fn.getreg('g'), true)<CR>gv]],
  { silent = true, desc = 'Google Lucky Search Selection' }
)

-- Compile and run
local function compile_and_run()
  vim.cmd('w')
  local ft = vim.bo.filetype
  if ft == 'c' then
    vim.fn.system('gcc ' .. vim.fn.expand('%') .. ' -o ' .. vim.fn.expand('%:r') .. ' && ./' .. vim.fn.expand('%:r'))
  elseif ft == 'java' then
    vim.fn.system('javac ' .. vim.fn.expand('%') .. ' && java ' .. vim.fn.expand('%:r'))
  elseif ft == 'javascript' then
    vim.fn.system('node ' .. vim.fn.expand('%'))
  elseif ft == 'sh' then
    vim.fn.system('bash ' .. vim.fn.expand('%'))
  elseif ft == 'python' then
    vim.fn.system('python ' .. vim.fn.shellescape(vim.fn.expand('%'), 1))
  end
end
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'java', 'javascript', 'sh', 'python' },
  callback = function()
    vim.keymap.set('n', '<leader>c', compile_and_run, { silent = true, buffer = true, desc = 'Compile and Run' })
  end,
})

-- Copy commands
local function copy_to_clipboard(cmd)
  local result = vim.fn.expand(cmd)
  vim.fn.setreg('*', result)
  print('Copied to clipboard: ' .. result)
end
vim.api.nvim_create_user_command('CopyFilename', function()
  copy_to_clipboard('%:t')
end, {})
vim.api.nvim_create_user_command('CopyPath', function()
  copy_to_clipboard('%:h')
end, {})
vim.api.nvim_create_user_command('CopyAbsolutePath', function()
  copy_to_clipboard('%:p:h')
end, {})
vim.api.nvim_create_user_command('CopyFilepath', function()
  copy_to_clipboard('%')
end, {})
vim.api.nvim_create_user_command('CopyAbsoluteFilepath', function()
  copy_to_clipboard('%:p')
end, {})
vim.keymap.set('n', '<leader>yfn', ':CopyFilename<CR>', { silent = true, desc = 'Copy Filename' })
vim.keymap.set('x', '<leader>yfn', ':CopyFilename<CR>', { silent = true, desc = 'Copy Filename' })
vim.keymap.set('n', '<leader>yp', ':CopyPath<CR>', { silent = true, desc = 'Copy Path' })
vim.keymap.set('x', '<leader>yp', ':CopyPath<CR>', { silent = true, desc = 'Copy Path' })
vim.keymap.set('n', '<leader>yap', ':CopyAbsolutePath<CR>', { silent = true, desc = 'Copy Absolute Path' })
vim.keymap.set('x', '<leader>yap', ':CopyAbsolutePath<CR>', { silent = true, desc = 'Copy Absolute Path' })
vim.keymap.set('n', '<leader>yfp', ':CopyFilepath<CR>', { silent = true, desc = 'Copy Filepath' })
vim.keymap.set('x', '<leader>yfp', ':CopyFilepath<CR>', { silent = true, desc = 'Copy Filepath' })
vim.keymap.set('n', '<leader>yafp', ':CopyAbsoluteFilepath<CR>', { silent = true, desc = 'Copy Absolute Filepath' })
vim.keymap.set('x', '<leader>yafp', ':CopyAbsoluteFilepath<CR>', { silent = true, desc = 'Copy Absolute Filepath' })
