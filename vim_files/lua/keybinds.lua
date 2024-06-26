local vim = vim
--  KEYBINDING: vim.keymap.set({mode}, {command}, {actions}, {opts})
-- set the leader key as space, usable in keybindings with <leader>
vim.g.mapleader = ' '
-- open Ex sostituito da oil
-- vim.keymap.set("n", "<leader>e", vim.cmd.Ex)

--copy and paste from the clipboard
vim.keymap.set({ 'n', 'x' }, '<leader>y', '"+y', { desc = "copy by system clipboard" })
vim.keymap.set({ 'n', 'x' }, '<leader>d', '"+d', { desc = "cut by system clipboard" })
vim.keymap.set({ 'n', 'x' }, '<leader>p', '"+p', { desc = "paste by system clipboard" })
-- comandi di selezione e movimento personalizzati
-- shift + arrow
vim.keymap.set({ 'n', 'v' }, "<S-h>", "5h", { desc = "move and select word back" })
vim.keymap.set({ 'n', 'v' }, "<S-l>", "5l", { desc = "move and select word up" })
vim.keymap.set({ 'n', 'v' }, "<S-j>", "5j", { desc = "selec" })
vim.keymap.set({ 'n', 'v' }, "<S-k>", "5k", { desc = "select 5 line up" })
-- leader + arrow
vim.keymap.set({ 'n', 'v' }, "<C-h>", "<C-w>h", { desc = "select begin of line" })
vim.keymap.set({ 'n', 'v' }, "<C-l>", "<C-w>l", { desc = "select end of line" })
vim.keymap.set({ 'n', 'v' }, "<C-j>", "<C-w>j", { desc = "selec" })
vim.keymap.set({ 'n', 'v' }, "<C-k>", "<C-w>k", { desc = "select 5 line up" })
--leader + shift + arrow
vim.keymap.set({ 'n', 'v' }, "<leader>h", "0", { desc = "select begin of line" })
vim.keymap.set({ 'n', 'v' }, "<leader>l", "$", { desc = "select end of line" })
vim.keymap.set({ 'n', 'v' }, "<leader>j", "G", { desc = "selec" })
vim.keymap.set({ 'n', 'v' }, "<leader>k", "gg", { desc = "select 5 line up" })
-- switch buffer
vim.keymap.set("n", "<Tab>", vim.cmd.bNext, { desc = "jump to next buffer open" })
vim.keymap.set("n", "<leader>q", vim.cmd.bd, { desc = "close current buffer" })

-- page mover and center cursor
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "down page and center cursor" })
vim.keymap.set("n", "<C-S-d>", "<C-u>zz", { desc = "up page and center cursor" })
-- find and replace
vim.keymap.set("n", "<leader>r", ":%s/", { desc = "enter in find and replace mode" })
vim.keymap.set("v", "<leader>r", ":s/", { desc = "delete and enter in insert mode" })
-- redo and undo
vim.keymap.set("n", "u", "u", { desc = "undo" })
vim.keymap.set("n", "U", "<C-r>", { desc = "redo" })
