local vim = vim
local lsp = require('lsp-zero')
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

lsp.on_attach(lsp.buffer_autoformat)

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {},
    handlers = {
        lsp.default_setup,
        require('lspconfig').rust_analyzer.setup,
    }
})

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<Tab>'] = cmp_action.tab_complete(),
        ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<Space>'] = cmp.mapping.confirm({ select = false }),
    })
})

vim.keymap.set('n', '<leader>dd', vim.lsp.buf.definition, { silent = true, desc = 'Go to definition' })
vim.keymap.set('n', '<leader>dD', vim.lsp.buf.references, { silent = true, desc = 'Go to implementation' })
vim.keymap.set('n', '<leader>d', vim.lsp.buf.hover, { silent = true, desc = 'detail' })

vim.opt.updatetime = 1000
vim.cmd("highlight LspDiagnosticsLineNrWarning guifg=#E5C07B guibg=#4E4942 gui=bold")
vim.diagnostic.config({
    virtual_text = {
        format = function(_)
            return string.format("!!")
        end,
        prefix = '',
    },
    float = {
        source = 'always',
        focusable = false,
        border = 'rounded',
    },
})
vim.api.nvim_create_autocmd('CursorHold', {
    callback = vim.diagnostic.open_float
})
