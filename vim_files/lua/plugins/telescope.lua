local vim = vim
-- shortcut for use telescome finder
require('telescope').setup({
    defaults = {
        preview = {
            treesitter = false,
        },
    },
})
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "telescope find file in dir" })
vim.keymap.set('n', '<leader>fw', builtin.live_grep, { desc = "telescope find word in dir" })
vim.keymap.set('v', '<leader>fw', builtin.grep_string, { desc = "telescope finder of word evedenced" })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "telescope see opened buffers" })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "telescope find help files" })
vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = "telescope see keymaps" })
-- comments fuzzy finder
vim.keymap.set('n', '<leader>fc', vim.cmd.TodoTelescope, { desc = "telescope find particolar comment" })
-- note archive fuzzy finder
local notes_home = "$NOTES_HOME"
vim.keymap.set('n', '<leader>nf', function()
    builtin.find_files({ cwd = notes_home })
end, { desc = "telescope find file in note dir" })
vim.keymap.set('n', '<leader>nw', function()
    builtin.live_grep({ cwd = notes_home .. "/index" })
end, { desc = "telescope find note in note dir" })
