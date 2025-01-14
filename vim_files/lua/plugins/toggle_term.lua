return {
        'akinsho/toggleterm.nvim',
        version = "*",
        config = function()
            require("toggleterm").setup {
                direction = 'float',
            }
            vim.keymap.set("n", "<C-t>", vim.cmd.ToggleTerm)
            vim.keymap.set("t", "<C-t>", vim.cmd.ToggleTerm)
        end
    }
