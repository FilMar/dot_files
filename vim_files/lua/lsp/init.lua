require('lsp.diagnostics')
require('lsp.keymaps')
require('lsp.commands')

local servers_path = vim.fn.stdpath('config') .. '/lua/lsp/servers'
for name, type in vim.fs.dir(servers_path) do
  if type == 'file' and name:match('%.lua$') then
    require('lsp.servers.' .. name:gsub('%.lua$', ''))
  end
end