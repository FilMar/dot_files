local lsp_zero = require('lsp-zero')
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()
local vim = vim


lsp_zero.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp_zero.buffer_autoformat()
end)
lsp_zero.setup_servers({ 'lua_ls', 'pylsp', 'docker_compose_language_service' })

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {},
    handlers = {
        lsp_zero.default_setup,
    },
})

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<Tab>'] = cmp_action.tab_complete(),
        ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<Space>'] = cmp.mapping.confirm({ select = false }),
    })
})

vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { silent = true })
vim.keymap.set('n', 'gi', vim.lsp.buf.hover, { silent = true })
vim.keymap.set('n', 'gli', vim.lsp.buf.implementation, { silent = true })
vim.keymap.set('n', 'glr', vim.lsp.buf.references, { silent = true })
vim.keymap.set('n', 'gld', vim.diagnostic.open_float, { silent = true })
