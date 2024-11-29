local vim = vim
local lsp = require('lsp-zero')
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()


require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {
        "rust_analyzer",
        "gopls",
        "pylsp",
    },
    handlers = {
        lsp.default_setup,
        require('lspconfig').rust_analyzer.setup,
        require('lspconfig').pylsp.setup,
        require('lspconfig').gopls.setup,
        require('lspconfig').html.setup,
        require('lspconfig').htmx.setup,
        require('lspconfig').tailwindcss.setup,
    }
})

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<Tab>'] = cmp_action.tab_complete(),
        ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<Return>'] = cmp.mapping.confirm({ select = false }),
    })
})

vim.keymap.set('n', '<leader>dd', vim.lsp.buf.definition, { silent = true, desc = 'Go to definition' })
vim.keymap.set('n', '<leader>dD', vim.lsp.buf.references, { silent = true, desc = 'Go to implementation' })
vim.keymap.set('n', '<leader>d', vim.lsp.buf.hover, { silent = true, desc = 'detail' })
vim.keymap.set('n', '<leader>df', vim.lsp.buf.format, { silent = true, desc = 'format file' })

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
    callback = function()
        vim.diagnostic.open_float({ scope = 'line' })
    end
})

-- linters
require("lint").linters_by_ft = {
    python = {"ruff" },
    lua = { "luacheck" },
}
require("mason-nvim-lint").setup({
    ensure_installed = {
        "ruff",
        "luacheck"
    }

})
