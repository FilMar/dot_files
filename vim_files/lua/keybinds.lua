local vim = vim
vim.g.mapleader = ' '

-- ═══ CLIPBOARD ═══
vim.keymap.set({ 'n', 'x' }, '<leader>cy', '"+y', { desc = "Copy to clipboard" })
vim.keymap.set({ 'n', 'x' }, '<leader>cx', '"+d', { desc = "Cut to clipboard" })
vim.keymap.set({ 'n', 'x' }, '<leader>cp', '"+p', { desc = "Paste from clipboard" })

-- ═══ BUFFERS ═══
vim.keymap.set("n", "<Tab>", vim.cmd.bnext, { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab", vim.cmd.bprevious, { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>q", vim.cmd.bdelete, { desc = "Delete buffer" })

-- ═══ WINDOWS ═══
vim.keymap.set({ 'n', 'v' }, "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set({ 'n', 'v' }, "<C-l>", "<C-w>l", { desc = "Window right" })
vim.keymap.set({ 'n', 'v' }, "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set({ 'n', 'v' }, "<C-k>", "<C-w>k", { desc = "Window up" })

-- ═══ MOVEMENT ═══
-- Fast movement (5x speed)
vim.keymap.set({ 'n', 'v' }, "<S-h>", "5h", { desc = "Move 5 left" })
vim.keymap.set({ 'n', 'v' }, "<S-l>", "5l", { desc = "Move 5 right" })
vim.keymap.set({ 'n', 'v' }, "<S-j>", "5j", { desc = "Move 5 down" })
vim.keymap.set({ 'n', 'v' }, "<S-k>", "5k", { desc = "Move 5 up" })

-- Extremes navigation
vim.keymap.set({ 'n', 'v' }, "<leader>h", "0", { desc = "Line start" })
vim.keymap.set({ 'n', 'v' }, "<leader>l", "$", { desc = "Line end" })
vim.keymap.set({ 'n', 'v' }, "<leader>j", "G", { desc = "File end" })
vim.keymap.set({ 'n', 'v' }, "<leader>k", "gg", { desc = "File start" })

-- Page navigation with centered cursor
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Down page and center cursor" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Up page and center cursor" })

-- ═══ SEARCH & REPLACE ═══
vim.keymap.set("n", "<leader>r", ":%s/", { desc = "Search and replace (global)" })
vim.keymap.set("v", "<leader>r", ":s/", { desc = "Search and replace (selection)" })

-- ═══ UNDO/REDO ═══
vim.keymap.set("n", "u", "u", { desc = "Undo" })
vim.keymap.set("n", "U", "<C-r>", { desc = "Redo" })

-- ═══ QUIT ═══
vim.api.nvim_create_user_command('Q', 'qa', {})
vim.cmd('cnoreabbrev q qa')
