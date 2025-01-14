return {
    "epwalsh/obsidian.nvim",
    version = "*",     -- recommended, use latest release instead of latest commit
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
        vim.keymap.set("n", "<leader>nr", ":ObsidianRename --dry-run<cr>",
            { desc = "rinomina nota sotto link o su buffer" })
    end
}
