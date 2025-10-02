return {
        'stevearc/oil.nvim',
        opts = {},
        -- Optional dependencies
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("oil").setup({
                show_hidden = true,
                keymaps = {
                    ["<leader><cr>"] = "actions.parent",
                },
            })
            vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File explorer" })
        end
    }
