return {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",         -- required
            "nvim-telescope/telescope.nvim", -- optional
        },
        config = function()
            require("neogit").setup({})
            vim.keymap.set("n", "<leader>g", vim.cmd.Neogit, { desc = "open neogit" })
        end
    }
