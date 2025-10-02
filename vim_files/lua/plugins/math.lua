return {
    'FilMar/nabla.nvim',
    config = function()
        vim.keymap.set("n", "<leader>m", ":lua require('nabla').popup()<cr>",
            { desc = "Math preview" })
    end
}
