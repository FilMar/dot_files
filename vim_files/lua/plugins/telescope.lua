local vim = vim

function Super_find_file(opts)
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local builtin = require('telescope.builtin')
    opts = opts or {}
    local cwd = opts.cwd or vim.loop.cwd() -- Usa la directory specificata o quella corrente

    builtin.find_files({
        cwd = cwd,
        attach_mappings = function(prompt, map)
            local create_file = function()
                local picker = action_state.get_current_picker(prompt)
                local file_name = picker:_get_prompt()
                actions.close(prompt)
                if file_name and file_name ~= "" then
                    file_name = cwd .. "/" .. file_name .. ".md"
                    vim.cmd("edit " .. file_name)
                else
                    print("file non specificato")
                end
            end

            map("i", "<cr>", function()
                local selection = action_state.get_selected_entry()
                if selection then
                    actions.select_default(prompt)
                else
                    create_file()
                end
            end)
            return true
        end,
    })
end

function Super_help_fullpage()
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local builtin = require('telescope.builtin')
    builtin.help_tags({
        attach_mappings = function(_, map)
            map("i", "<cr>", function(prompt)
                local selection = action_state.get_selected_entry()
                if selection then
                    actions.close(prompt)
                    vim.cmd("help " .. selection.value)
                    vim.cmd("only")
                end
            end)
            return true
        end,
    })
end

return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        require('telescope').setup({
            defaults = {
                preview = {
                    treesitter = true,
                },
                layout_strategy = 'horizontal',
                layout_config = {
                    horizontal = {
                        prompt_position = 'bottom',
                        preview_width = 0.6,
                        results_width = 0.8,
                    },
                    width = 0.9,
                    height = 0.85,
                    preview_cutoff = 120,
                },
                sorting_strategy = 'descending',
                winblend = 0,
                borderchars = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
                prompt_prefix = '  ',
                selection_caret = '  ',
                entry_prefix = '  ',
                results_title = '',
                prompt_title = '',
                preview_title = '',
            },
            pickers = {
                find_files = {
                    hidden = true,
                    no_ignore = false,
                    follow = true,
                },
                live_grep = {
                    additional_args = function() return {"--hidden"} end,
                },
                buffers = {
                    show_all_buffers = true,
                    sort_lastused = true,
                    mappings = {
                        i = { ["<c-d>"] = "delete_buffer" },
                        n = { ["dd"] = "delete_buffer" }
                    }
                }
            },
        })
        
        local builtin = require('telescope.builtin')
        
        -- ═══ FIND GROUP ═══
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files" })
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Grep in files" })
        vim.keymap.set('v', '<leader>fg', builtin.grep_string, { desc = "Grep selection" })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Find buffers" })
        vim.keymap.set('n', '<leader>fh', "<cmd>lua Super_help_fullpage()<CR>", { desc = "Find help" })
        vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = "Find keymaps" })
        vim.keymap.set('n', '<leader>fc', vim.cmd.TodoTelescope, { desc = "Find comments/todos" })
        vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = "Recent files" })
        
        -- ═══ NOTES ═══
        vim.keymap.set("n", "<leader>nf", "<cmd>lua Super_find_file({ cwd = '$NOTES_HOME'})<CR>",
            { desc = "Find notes" })
    end
}
