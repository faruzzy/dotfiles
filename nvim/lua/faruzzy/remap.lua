-- Quick buffer movement
vim.keymap.set('n', ']b', vim.cmd.bnext)
vim.keymap.set('n', '[b', vim.cmd.bprev)
-- Move to last buffer
vim.keymap.set('n', 'b<Tab>', '<cmd>b#<cr>')

-- Copying the vscode behaviour of making tab splits
-- vim.keymap.set('n', '<C-\\>', '<CMD>vsplit<CR>')
-- vim.keymap.set('n', '<A-\\>', '<CMD>split<CR>')

-- Reference: https://vim.fandom.com/wiki/Moving_lines_up_or_down
-- Move line up and down in NORMAL and VISUAL modes
vim.keymap.set('n', '<A-k>', '<CMD>move .-2<CR>')
vim.keymap.set('n', '<A-j>', '<CMD>move .+1<CR>')
vim.keymap.set('x', '<A-k>', ':move \'<-2<CR>gv=gv')
vim.keymap.set('x', '<A-j>', ':move \'>+1<CR>gv=gv')

-- Prevents moving cursor with the space key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
-- vim.keymap.set('i', '<c-j>', '<down>', {})
-- vim.keymap.set('i', '<c-k>', '<up>', {})
vim.keymap.set('i', '<c-h>', '<left>', {})
vim.keymap.set('i', '<c-l>', '<right>', {})
-- vim.keymap.set('i', '<C-y>', '<esc>yyp', {}) -- [ ctrl + y ] copy current line and paste next line

vim.keymap.set('n', '<Leader>x', ':x<CR>')
vim.keymap.set('n', '<Leader>X', ':wqa!<CR>')

-- Remap for dealing with word wrap
-- vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
-- vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- turn off highlighting until the next search
vim.keymap.set('n', '<Leader>n', ':noh<cr>')

vim.keymap.set('n', '<Leader>o', ':only<cr>') -- only show the current buffer
vim.keymap.set('n', '<Leader>O', ':!open .<cr>') -- open the current directory in finder

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Diagnostic Pevious Diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Diagnostic Next Diagnostic' })
vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float, { desc = 'Diagnostic Open Float Window' })

vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, { desc = 'Buffer Rename' })
vim.keymap.set('n', '<Leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action' })

-- GV
-- vim.keymap.set('n', '<Leader>gv', '<cmd>GV<cr>')
-- vim.keymap.set('n', '<Leader>Gv', '<cmd>GV!<cr>')

-- lsp-overloads
-- vim.api.nvim_set_keymap("n", "<A-s>", ":LspOverloadsSignature<CR>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("i", "<A-s>", "<cmd>LspOverloadsSignature<CR>", { noremap = true, silent = true })

-- diffs
vim.keymap.set('n', '<leader>gl', '<cmd>diffget //2<cr>')
vim.keymap.set('n', '<leader>gr', '<cmd>diffget //3<cr>')

-- run last command easily
local def_opts = { silent = false, noremap = true }
vim.keymap.set({ 'n', 'v' }, '<CR>', ':<up>', def_opts)

vim.keymap.set('n', '<leader>ti', function()
  local inlay_state = vim.lsp.inlay_hint.is_enabled(0)
  vim.lsp.inlay_hint.enable(0, not inlay_state)
end, { desc = 'Toggle Inlay Hints' })

vim.keymap.set('n', '<leader>ut', vim.cmd.UndotreeToggle) -- undotree

function CloseAllButCurrent()
  local current_buf = vim.fn.bufnr()
  local current_win = vim.fn.win_getid()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  for _, buf in ipairs(bufs) do
    if buf.bufnr ~= current_buf then
      vim.cmd('silent! bdelete ' .. buf.bufnr)
    end
  end
  vim.fn.win_gotoid(current_win)
end
vim.keymap.set('n', '<Leader>aq', function()
  CloseAllButCurrent()
end, { silent = true, desc = 'Close all other buffers except current one.' })

vim.cmd([[
function! s:goog(pat, lucky)
  let q = '"'.substitute(a:pat, '["\n]', ' ', 'g').'"'
  let q = substitute(q, '[[:punct:] ]',
    \ '\=printf("%%%02X", char2nr(submatch(0)))', 'g')
  call system(printf('open "https://www.google.com/search?%sq=%s"',
    \ a:lucky ? 'btnI&' : '', q))
endfunction

nnoremap <leader>? :call <SID>goog(expand("<cWORD>"), 0)<cr>
nnoremap <leader>! :call <SID>goog(expand("<cWORD>"), 1)<cr>
xnoremap <leader>? "gy:call <SID>goog(@g, 0)<cr>gv
xnoremap <leader>! "gy:call <SID>goog(@g, 1)<cr>gv
]])
