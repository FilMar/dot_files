local wk = require("which-key")
wk.setup({
    delay = 300,
    preset = "modern",
})

wk.add({
    { "<leader>f", group = "Find" },
    { "<leader>g", group = "Git" },
    { "<leader>d", group = "Diagnostics/LSP" },
    { "<leader>c", group = "Clipboard/Code" },
    { "<leader>b", group = "Buffers" },
    { "<leader>w", group = "Windows" },
    { "<leader>n", group = "Notes" },
    { "<leader>s", group = "Search/Replace" },
    { "<leader>L", group = "Lean" },
})

vim.keymap.set("n", "<leader>?", function()
    wk.show({ global = false })
end, { desc = "Buffer Local Keymaps (which-key)" })

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function()
        vim.defer_fn(function()
            pcall(wk.register)
        end, 100)
    end,
})
