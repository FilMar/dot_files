require('nvim-treesitter').setup({
    ensure_installed = { "c", "lua", "vim", "python", "dart", "bash", "typescript", "markdown" },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
})
