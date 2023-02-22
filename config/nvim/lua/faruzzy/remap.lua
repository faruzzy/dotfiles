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

-- Move line up and down in NORMAL and VISUAL modes
-- Reference: https://vim.fandom.com/wiki/Moving_lines_up_or_down
vim.keymap.set('n', '<C-M>', '<CMD>move .+1<CR>')
vim.keymap.set('n', '<C-L>', '<CMD>move .-2<CR>')
vim.keymap.set('x', '<C-M>', ":move '>+1<CR>gv=gv")
vim.keymap.set('x', '<C-L>', ":move '<-2<CR>gv=gv")

-- move to normal mode 
vim.api.nvim_set_keymap("i", "jk", "<esc>", {noremap = true})

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

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

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- vim.cmd [[let g:fugitive_pty = 0]]
vim.keymap.set('n', '<leader>gs', ':Git<CR>', { noremap = true })
vim.keymap.set('n', '<leader>gb', ':Git blame<CR>', { noremap = true })

-- leader-o/O inserts blank line below/above
vim.keymap.set('n', '<leader>o', 'o<ESC>')
vim.keymap.set('n', '<leader>O', 'O<ESC>')

-- turn off higlighting until the next search
vim.keymap.set('n', '<leader>n', ':noh<cr>')

-- This command prompts you to type one key, and will hint that key in the buffer.
vim.keymap.set('n', '<leader>,', ':HopChar1<cr>')

-- vim.keymap.set('n', '<leader>o', ':only<cr>') -- only show the current buffer
vim.keymap.set('n', '<leader>O', ':!open .<cr>') -- open the current directory in finder

-- fugitive
vim.keymap.set('n', '<leader>ga', ':Git add %:p<cr><cr>')
vim.keymap.set('n', '<leader>gw', ':Gwrite<cr>')
vim.keymap.set('n', '<leader>gr', ':Gread<cr> :w<cr>')
vim.keymap.set('n', '<leader>gm', ':Gmove<cr>')
vim.keymap.set('n', '<leader>gy', ':Gremove<cr>')
vim.keymap.set('n', '<leader>gs', ':Git<cr>')
vim.keymap.set('n', '<leader>gl', ':Git pull<cr>')
vim.keymap.set('n', '<leader>gc', ':Git commit<cr>')
vim.keymap.set('n', '<leader>gd', ':Gdiffsplit<cr>')
vim.keymap.set('n', '<leader>gb', ':Git blame<cr>')
vim.keymap.set('n', '<leader>gg', ':Gmerge<cr>')
vim.keymap.set('n', '<leader>pp', ':Git push origin master<cr>')

-- GV
vim.keymap.set('n', '<leader>gv', ':GV')
vim.keymap.set('n', '<leader>Gv', ':GV!')