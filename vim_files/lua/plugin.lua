local vim = vim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
    -- theme
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("catppuccin-mocha")
            if not vim.g.neovide then
                vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
                vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
            end
        end
    },
    -- telescope
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.4',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            require("plugins.telescope")
        end
    },
    -- treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        config = function()
            require("plugins.treesitter")
            vim.cmd(':TSUpdate')
        end,
        dependencies = { "nvim-treesitter/playground" }
    },
    --undotree
    {
        'mbbill/undotree',
        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        end
    },
    --toggleterm
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        config = function()
            require("toggleterm").setup {
                direction = 'float',
            }
            vim.keymap.set("n", "<C-t>", vim.cmd.ToggleTerm)
            vim.keymap.set("t", "<C-t>", vim.cmd.ToggleTerm)
        end
    },
    --lspzero
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        dependencies = {
            { 'neovim/nvim-lspconfig' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/nvim-cmp' },
            { 'L3MON4D3/LuaSnip' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },
        },
        config = function()
            require("plugins.lsp")
        end
    },
    -- statusbar
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons', opt = true },
        config = function()
            require('lualine').setup({
                theme = 'auto', -- lualine theme
            })
        end
    },
    -- todo comments
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("todo-comments").setup()
        end
    },
    -- vim_be_good
    { 'ThePrimeagen/vim-be-good' },
    -- oil
    {
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
            vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { noremap = true, silent = true })
        end
    },
    -- rainbow-sql
    {
        'cameron-wags/rainbow_csv.nvim',
        config = true,
        ft = {
            'csv',
            'tsv',
            'csv_semicolon',
            'csv_whitespace',
            'csv_pipe',
            'rfc_csv',
            'rfc_semicolon'
        },
        cmd = {
            'RainbowDelim',
            'RainbowDelimSimple',
            'RainbowDelimQuoted',
            'RainbowMultiDelim'
        }
    },
    -- neogit
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",         -- required
            "nvim-telescope/telescope.nvim", -- optional
        },
        config = function()
            require("neogit").setup({})
            vim.keymap.set("n", "<leader>g", vim.cmd.Neogit, { desc = "open neogit" })
        end
    },
    -- open url in browser
    {
        "sontungexpt/url-open",
        event = "VeryLazy",
        cmd = "URLOpenUnderCursor",
        config = function()
            local status_ok, url_open = pcall(require, "url-open")
            if not status_ok then
                return
            end
            url_open.setup({
                highlight_url = {
                    all_urls = {
                        fg = "text", -- text will set underline same color with text
                        underline = true,
                    },
                },
            })
            vim.keymap.set("n", "<leader>b", ":URLOpenUnderCursor<CR>", { noremap = true, silent = true })
        end,

    },
    -- lint-nvim
    {
        "mfussenegger/nvim-lint",
        dependencies = {
            "rshkarin/mason-nvim-lint",
        },
    },
    -- obsidian
    {
        "epwalsh/obsidian.nvim",
        version = "*", -- recommended, use latest release instead of latest commit
        lazy = true,
        ft = "markdown",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },

        config = function()
            vim.opt.conceallevel = 1
            require("obsidian").setup({
                ui = {
                    enable = false
                },
                workspaces = {
                    {
                        name = "notes",
                        path = "~/MEGA/2_areas/notes/",
                    }
                },
                note_frontmatter_func = function(note)
                    local out = { tags = note.tags }
                    if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
                        for k, v in pairs(note.metadata) do
                            out[k] = v
                        end
                    end
                    return out
                end,
                note_id_func = function(title)
                    return title
                end,
            })
            vim.keymap.set("n", "<leader>of", ":ObsidianFollowLink<CR>")
            vim.keymap.set("n", "<leader>ob", ":ObsidianBacklinks<CR>")
        end,
    },
    -- markdown
    {
        "preservim/vim-markdown",
        config = function()
            vim.g.vim_markdown_conceal = 2         -- Abilita il concealing avanzato
            vim.g.vim_markdown_conceal_code_blocks = 0 -- Mostra i blocchi di codice
            vim.g.vim_markdown_folding_disabled = 1 -- Disabilita il folding
        end,
    }
}
require("lazy").setup(plugins, opts)
