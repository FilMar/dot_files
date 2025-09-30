require('lsp.diagnostics')
require('lsp.keymaps')
require('lsp.commands')

-- Lista degli LSP server da disabilitare (usa il nome del file, non del server)
local disabled_servers = {
    -- "lua",        -- riabilitato lua.lua (server lua_ls)
    -- "lean",       -- decommentare per disabilitare lean LSP
    -- "python",     -- decommentare per disabilitare python LSP
    -- "rust",       -- decommentare per disabilitare rust LSP
}

-- Crea set per lookup veloce
local disabled_set = {}
for _, server in ipairs(disabled_servers) do
    disabled_set[server] = true
end

-- Carica automaticamente tutti gli LSP server tranne quelli disabilitati
local servers_path = vim.fn.stdpath('config') .. '/lua/lsp/servers'
for name, file_type in vim.fs.dir(servers_path) do
    if file_type == 'file' and name:match('%.lua$') then
        local server_name = name:gsub('%.lua$', '')
        if not disabled_set[server_name] then
            local ok, err = pcall(require, 'lsp.servers.' .. server_name)
            if not ok then
                print("Errore caricando LSP server " .. server_name .. ": " .. tostring(err))
            end
        end
    end
end
