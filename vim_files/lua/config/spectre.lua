require("spectre").setup()
vim.keymap.set("n", "<leader>R", "<cmd>lua require('spectre').open()<CR>", { desc = "Open Spectre" })
