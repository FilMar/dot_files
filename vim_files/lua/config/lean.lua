require('lean').setup({
    mappings = false,
    lsp = { enable = true },
    stderr = { enable = true },
    infoview = {
        autoopen = true,
        width = 50,
        height = 20,
        orientation = "horizontal",
        horizontal_position = "bottom"
    },
})

vim.keymap.set('n', '<leader>Li', '<cmd>LeanInfoviewToggle<cr>', { desc = 'Toggle Lean infoview' })
vim.keymap.set('n', '<leader>Lr', '<cmd>LeanRestartServer<cr>', { desc = 'Restart Lean server' })
vim.keymap.set('n', '<leader>Ls', '<cmd>LeanGoalState<cr>', { desc = 'Show goal state' })
vim.keymap.set('n', '<leader>Lt', '<cmd>LeanTermGoal<cr>', { desc = 'Show term goal' })
vim.keymap.set('n', '<leader>Lp', '<cmd>LeanInfoviewPause<cr>', { desc = 'Pause infoview' })
vim.keymap.set('n', '<leader>Lu', '<cmd>LeanInfoviewUnpause<cr>', { desc = 'Unpause infoview' })
vim.keymap.set('n', '<leader>Lc', '<cmd>LeanInfoviewClear<cr>', { desc = 'Clear infoview' })
vim.keymap.set('n', '<leader>Lf', '<cmd>LeanInfoviewPinToggle<cr>', { desc = 'Toggle pin infoview' })
