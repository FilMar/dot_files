vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        local config_path = vim.fn.stdpath('config') .. '/lua/config'
        for name, file_type in vim.fs.dir(config_path) do
            if file_type == 'file' and name:match('%.lua$') and name ~= 'init.lua' then
                local module_name = name:gsub('%.lua$', '')
                local ok, err = pcall(require, 'config.' .. module_name)
                if not ok then
                    vim.notify('Errore caricando config.' .. module_name .. ': ' .. err, vim.log.levels.ERROR)
                end
            end
        end
    end,
})
