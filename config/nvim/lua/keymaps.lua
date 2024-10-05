-- KEYMAPS
vim.g.mapleader = ' '
vim.g.maplocalleader = ''

vim.keymap.set({ 'n', 'x' }, 'x', '"_x')
vim.keymap.set({ 'n', 'x' }, 'X', '"_d')
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous Diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next Diagnostic message' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Show diagnostic Error messages' })

-- Keybinds to make split navigation easier.
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- buffer
vim.keymap.set('n', '<leader>w', '<cmd>write<CR>', { desc = 'Save current buffer' })
vim.keymap.set('n', '<leader>q', '<cmd>quit<CR>', { desc = 'Quit current window' })
vim.keymap.set('n', '<leader>bn', '<cmd>bnext<CR>', { desc = 'Go to next buffer' })
vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<CR>', { desc = 'Go to previous buffer' })
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = 'Delete current buffer' })
