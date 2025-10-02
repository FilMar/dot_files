return {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",         -- required
            "nvim-telescope/telescope.nvim", -- optional
        },
        config = function()
            require("neogit").setup({
                disable_signs = false,
                disable_hint = false,
                disable_context_highlighting = false,
                disable_commit_confirmation = false,
                auto_refresh = true,
                sort_branches = "-committerdate",
                kind = "tab",
                console_timeout = 2000,
                auto_show_console = true,
                integrations = {
                    telescope = true,
                },
            })
            
            -- ═══ GIT GROUP ═══
            vim.keymap.set("n", "<leader>gg", vim.cmd.Neogit, { desc = "Git status" })
            vim.keymap.set("n", "<leader>gc", ":Neogit commit<CR>", { desc = "Git commit" })
            vim.keymap.set("n", "<leader>gp", ":Neogit push<CR>", { desc = "Git push" })
            vim.keymap.set("n", "<leader>gl", ":Neogit pull<CR>", { desc = "Git pull" })
        end
    }
