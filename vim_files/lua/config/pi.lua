require("pi").setup({
    binary= "/home/filippo/.local/bin/pi",
    provider = "ollama",
    model = "glm-5.3:cloud"
})
-- Ask pi with the current buffer as context
vim.keymap.set("n", "<leader>n", ":PiAsk<CR>", { desc = "Ask pi" })

-- Ask pi with visual selection as context
vim.keymap.set("v", "<leader>n", ":PiAskSelection<CR>", { desc = "Ask pi (selection)" })
