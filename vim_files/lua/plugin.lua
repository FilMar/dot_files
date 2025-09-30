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

-- Auto-load all plugins except disabled ones
local plugins = {}

-- Lista dei plugin da disabilitare (commenta/decommenta per attivare/disattivare)
local disabled_plugins = {
    -- "which_key",  -- riabilitato
    -- "lean",       -- decommentare per disabilitare lean
    -- "obsidian",   -- decommentare per disabilitare obsidian
    -- "ai",         -- decommentare per disabilitare ai
}

-- Crea set per lookup veloce
local disabled_set = {}
for _, plugin in ipairs(disabled_plugins) do
    disabled_set[plugin] = true
end

-- Carica automaticamente tutti i plugin dalla cartella
local plugins_path = vim.fn.stdpath('config') .. '/lua/plugins'
for name, file_type in vim.fs.dir(plugins_path) do
    if file_type == 'file' and name:match('%.lua$') then
        local plugin_name = name:gsub('%.lua$', '')
        if not disabled_set[plugin_name] then
            local ok, plugin = pcall(require, 'plugins.' .. plugin_name)
            if ok and type(plugin) == 'table' then
                table.insert(plugins, plugin)
            elseif ok then
                print("Plugin " .. plugin_name .. " non ritorna una table (tipo: " .. type(plugin) .. ")")
            else
                print("Errore caricando plugin " .. plugin_name .. ": " .. tostring(plugin))
            end
        end
    end
end
require("lazy").setup(plugins, opts)
