-- shortcut for use telescome finder
require('telescope').setup({
  defaults = {
    preview = {
      treesitter = false,
    },
  },
})
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {desc = "telescope find file in dir"})
vim.keymap.set('n', '<leader>fw', builtin.live_grep, {desc = "telescope find word in dir"})
vim.keymap.set('v', '<leader>fw', builtin.grep_string, {desc = "telescope finder of word evedenced"})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {desc = "telescope see opened buffers"})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {desc = "telescope find help files"})
vim.keymap.set('n', '<leader>fk', builtin.keymaps, {desc = "telescope see keymaps"})
-- treesitter fuzzy finder
vim.keymap.set('n', '<leader>ft', builtin.treesitter, {desc = "telescope see tree struct of file"})
-- lsp fuzzy finder
vim.keymap.set('n', '<leader>fr', builtin.lsp_references, {desc = "telescope find reference of under the cursor"})
vim.keymap.set('n', '<leader>fd', builtin.diagnostics, {desc = "telescope find file errors"})
-- comments fuzzy finder
vim.keymap.set('n', '<leader>fc', vim.cmd.TodoTelescope, {desc = "telescope find particolar comment"})
vim.keymap.set("n", "<space>fm", ":Telescope file_browser<CR>",{ desc = "telescope file manager"}
)
