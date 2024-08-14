vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)
-- Move to last buffer
vim.keymap.set('n', 'b<Tab>', '<cmd>b#<cr>')

-- Quick buffer movement
vim.keymap.set('n', ']b', vim.cmd.bnext)
vim.keymap.set('n', '[b', vim.cmd.bprev)

-- Move to the next/previous buffer
-- map('n', '<leader>[', '<CMD>bp<CR>')
-- map('n', '<leader>]', '<CMD>bn<CR>')

-- Copying the vscode behaviour of making tab splits
-- vim.keymap.set('n', '<C-\\>', '<CMD>vsplit<CR>')
-- vim.keymap.set('n', '<A-\\>', '<CMD>split<CR>')

-- Reference: https://vim.fandom.com/wiki/Moving_lines_up_or_down
-- Move line up and down in NORMAL and VISUAL modes
vim.keymap.set('n', '<A-k>', '<CMD>move .-2<CR>')
vim.keymap.set('n', '<A-j>', '<CMD>move .+1<CR>')
vim.keymap.set('x', '<A-k>', ":move '<-2<CR>gv=gv")
vim.keymap.set('x', '<A-j>', ":move '>+1<CR>gv=gv")

-- Prevents moving cursor with the space key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
-- vim.keymap.set('i', '<c-j>', '<down>', {})
-- vim.keymap.set('i', '<c-k>', '<up>', {})
vim.keymap.set('i', '<c-h>', '<left>', {})
vim.keymap.set('i', '<c-l>', '<right>', {})
-- vim.keymap.set('i', '<C-y>', '<esc>yyp', {}) -- [ ctrl + y ] copy current line and paste next line

vim.keymap.set('n', '<leader>x', ':x<CR>')
vim.keymap.set('n', '<leader>X', ':wqa!<CR>')
-- vim.keymap.set('n', '<leader>w', vim.cmd.update)
-- Quickly save the current buffer or all buffers
vim.keymap.set('n', '<leader>w', '<CMD>update<CR>')
vim.keymap.set('n', '<leader>W', '<CMD>wall<CR>')
-- vim.keymap.set('n', '<leader>w', ':w<CR>')

vim.keymap.set('n', '<leader>vr', ':VimuxPromptCommand<cr>')
vim.keymap.set('n', '<leader>vc', ':call VimuxCloseRunner()<cr>')
vim.keymap.set('n', '<leader>vl', ':VimuxRunLastCommand<cr>')
vim.keymap.set('n', '<leader>vi', ':VimuxInterruptRunner<cr>')
vim.keymap.set('n', '<leader>vz', ':VimuxZoomRunner<cr>')
vim.keymap.set('n', '<leader>vt', ':VimuxTogglePane<cr>')

-- Remap for dealing with word wrap
-- vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
-- vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- turn off higlighting until the next search
vim.keymap.set('n', '<leader>n', ':noh<cr>')

-- This command prompts you to type one key, and will hint that key in the buffer.
vim.keymap.set('n', '<leader>,', ':HopChar1<cr>')

vim.keymap.set('n', '<leader>o', ':only<cr>') -- only show the current buffer
vim.keymap.set('n', '<leader>O', ':!open .<cr>') -- open the current directory in finder

-- fugitive
vim.keymap.set('n', '<leader>ga', ':Git add %:p<cr><cr>')
vim.keymap.set('n', '<leader>gm', ':Gmove<cr>')
vim.keymap.set('n', '<leader>gy', ':Gremove<cr>')
vim.keymap.set('n', '<leader>gl', ':Git pull<cr>')
vim.keymap.set('n', '<leader>gc', ':Git commit<cr>')
vim.keymap.set('n', '<leader>gd', ':Gvdiffsplit<cr>')
vim.keymap.set('n', '<leader>gs', ':Git<cr>', { noremap = true })
vim.keymap.set('n', '<leader>gg', ':Gmerge<cr>')
vim.keymap.set('n', '<leader>pp', ':Git push origin master<cr>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
-- TODO: ensure this is working 
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- GV
vim.keymap.set('n', '<leader>gv', ':GV<cr>')
vim.keymap.set('n', '<leader>Gv', ':GV!<cr>')

-- lsp-overloads
-- vim.api.nvim_set_keymap("n", "<A-s>", ":LspOverloadsSignature<CR>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("i", "<A-s>", "<cmd>LspOverloadsSignature<CR>", { noremap = true, silent = true })

-- diffs
vim.keymap.set('n', '<leader>gl', '<cmd>diffget //2<cr>')
vim.keymap.set('n', '<leader>gr', '<cmd>diffget //3<cr>')

-- vim-bbye
vim.keymap.set('n', '<leader>q', ':Bwipeout<CR>')

-- run last command easily
local def_opts = { silent = false, noremap = true }
vim.keymap.set({ 'n', 'v' }, '<CR>', ':<up>', def_opts)

vim.keymap.set('n', '<leader>ti', function ()
  local inlay_state = vim.lsp.inlay_hint.is_enabled(0)
  vim.lsp.inlay_hint.enable(0, not inlay_state)
end, { desc = 'Toggle Inlay Hints' })

vim.keymap.set('n', '<leader>ut', vim.cmd.UndotreeToggle) -- undotree
