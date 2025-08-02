return {
    "epwalsh/obsidian.nvim",
    version = "*", -- Usa l'ultima release stabile
    lazy = true,
    ft = "markdown",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        local vim = vim
        require("obsidian").setup({
            -- Percorso principale del vault

            workspaces = {
                {
                    name = "wandering_sun",
                    path = "~/mega/1_projects/wandering_sun",
                },
            },
            attachments = {
                img_folder = "~/mega/1_projects/wandering_sun/attachments",
            },
            -- Disabilita la UI integrata
            ui = {
                enable = false,
            },
            ---@param title string|?
            ---@return string
            note_id_func = function(title)
                if title then
                    return title
                else
                    return "###"
                end
            end,

            -- Optional, customize how note file names are generated given the ID, target directory, and title.
            ---@param spec { id: string, dir: obsidian.Path, title: string|? }
            ---@return string|obsidian.Path The full path to the new note.
            note_path_func = function(spec)
                -- This is equivalent to the default behavior.
                local path = spec.dir / tostring(spec.id)
                return path:with_suffix(".md")
            end,

            ---@param url string
            follow_url_func = function(url)
                vim.fn.jobstart({ "brave", url }) -- linux
            end,

            -- Disabilita frontmatter
            disable_frontmatter = true,
            -- Integrazione con Telescope
            picker = {
                name = "telescope.nvim",
            },
        })

        local function update_attachments_index()
            local attach_dir = "~/mega/2_areas/notes/attachments/"
            local index = "~/mega/2_areas/notes/attachments.md"
            local files = vim.fn.globpath(attach_dir, "*", false, true)
            local lines = {}
            for _, attach in pairs(files) do
                local attach_name = vim.fn.fnamemodify(attach, ":t")
                attach_name = attach_name:gsub("%.%w+$", "")
                table.insert(lines, "# " .. attach_name)
                table.insert(lines, "[" .. attach_name .. "](file:///" .. attach .. ")")
            end
            local index_f = io.open(vim.fn.expand(index), "w")
            if index_f then
                index_f:write(table.concat(lines, "\n"))
                index_f:close()
            end
        end
        update_attachments_index()
        -- Keymaps personalizzate
        vim.keymap.set("n", "<leader>na", update_attachments_index,
            { desc = "aggiorna indice degli attachments" })
        vim.keymap.set("n", "<leader>nn", ":ObsidianFollowLink<cr>",
            { desc = "segui il wikilink ed apri la nuova nota" })
        vim.keymap.set("n", "<leader>n<S-n>", ":ObsidianBacklinks<cr>",
            { desc = "lista link a nota corrente" })
        vim.keymap.set("n", "<leader>nw", ":ObsidianSearch<cr>", { desc = "cerca parola in tutto il vault" })
        vim.keymap.set("n", "<leader>nr", ":ObsidianRename --dry-run<cr>",
            { desc = "rinomina nota sotto link o su buffer" })
    end,
}
