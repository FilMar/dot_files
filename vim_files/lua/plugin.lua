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
    require "plugins.catpuccine",
    -- LSP Config
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
        },
        config = function()
            -- LSP Configuration (dettagliata sotto)
            require("plugins.lsp")
        end,
    },
    --telescope
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
    -- lint-nvim
    {
        "mfussenegger/nvim-lint",
        dependencies = {
            "rshkarin/mason-nvim-lint",
        },
    },
    -- markdown render
    {
        'MeanderingProgrammer/render-markdown.nvim',
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
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
            require("obsidian").setup {
                ui = {
                    enable = false
                },
                workspaces = {
                    {
                        name = "notes",
                        path = "~/mega/2_areas/notes",
                    },
                },

                picker = {
                    name = "telescope.nvim",
                },
                mapping = {
                    ["<leader>nn"] = {
                        action = function()
                            return vim.cmd
                        end,
                        opts = { buffer = true },
                    },
                },
                ---@return table
                note_frontmatter_func = function(note)
                    -- Add the title of the note as an alias.
                    if note.title then
                        note:add_alias(note.title)
                    end
                    local out = { id = note.id, aliases = note.aliases, tags = note.tags }
                    -- `note.metadata` contains any manually added fields in the frontmatter.
                    -- So here we just make sure those fields are kept in the frontmatter.
                    if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
                        for k, v in pairs(note.metadata) do
                            out[k] = v
                        end
                    end
                    return {}
                end,
                ---@param title string|?
                ---@return string
                note_id_func = function(title)
                    if title then
                        return title
                    else
                        return ""
                    end
                end,
                ---@param spec { id: string, dir: obsidian.Path, title: string|? }
                ---@return string|obsidian.Path The full path to the new note.
                note_path_func = function(spec)
                    -- This is equivalent to the default behavior.
                    local path = spec.dir / tostring(spec.id)
                    return path:with_suffix(".md")
                end,
            }
            vim.keymap.set("n", "<leader>nn", ":ObsidianFollowLink<cr>",
                { desc = "segui il wikilink ed apri la nuova nota" })
            vim.keymap.set("n", "<leader>n<S-n>", ":ObsidianBacklinks<cr>",
                { desc = "lista link a nota corrente" })
            vim.keymap.set("n", "<leader>nw", ":ObsidianSearch<cr>", { desc = "cerca parola in tutto il vault" })
            vim.keymap.set("n", "<leader>nr", ":ObsidianRename --dry-run<cr>", { desc = "rinomina nota sotto link o su buffer" })
        end
    },
    -- notifier
    {
        'rcarriga/nvim-notify',
        config = function ()
            require("notify").setup()
        end
    }

}
require("lazy").setup(plugins, opts)
