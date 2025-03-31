return {
    'nvim-treesitter/nvim-treesitter',
    config = function()
        local vim = vim
        require('nvim-treesitter.configs').setup {
            ensure_installed = { "c", "lua", "vim", "python", "dart", "bash", "typescript", "markdown" },
            sync_install = false,
            auto_install = true,
            highlight = {
                -- `false` will disable the whole extension
                enable = true,
                disable = function(_, bufnr)
                    return vim.api.nvim_buf_line_count(bufnr) > 5000
                end,
                -- Instead of true it can also be a list of languages
                additional_vim_regex_highlighting = false,
            },
        }
        vim.cmd(':TSUpdate')
    end,
}
