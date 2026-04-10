require("oil").setup({
    show_hidden = true,
    keymaps = {
        ["<leader><cr>"] = "actions.parent",
    },
})
vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File explorer" })
