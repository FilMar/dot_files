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
        -- shortcut for use telescome finder
        require('telescope').setup({
            defaults = {
                preview = {
                    treesitter = true,
                },
            },
        })
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "telescope find file in dir" })
        vim.keymap.set('n', '<leader>F', builtin.live_grep, { desc = "telescope find word in dir" })
        vim.keymap.set('v', '<leader>F', builtin.grep_string, { desc = "telescope finder of word evedenced" })
        vim.keymap.set('n', '<leader>fh', "<cmd>lua Super_help_fullpage()<CR>", { desc = "telescope find help files" })
        vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = "telescope see keymaps" })
        -- comments fuzzy finder
        vim.keymap.set('n', '<leader>fc', vim.cmd.TodoTelescope, { desc = "telescope find particolar comment" })
        -- note archive fuzzy finder
        vim.keymap.set("n", "<leader>nf", "<cmd>lua Super_find_file({ cwd = '$NOTES_HOME'})<CR>",
            { noremap = true, silent = true })

    end
}
