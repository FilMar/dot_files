local vim = vim
local cmp = require('cmp')

-- Configura Mason
require('mason').setup({})

-- Configura Mason-LSPConfig
require('mason-lspconfig').setup({})

-- Configurazione di base degli LSP
local lspconfig = require('lspconfig')
local on_attach = function(client)
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set('n', '<leader>dd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', '<leader>dD', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<leader>d', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', '<leader>df', vim.lsp.buf.format, bufopts)
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Configura i server supportati
local servers = {
    rust_analyzer = {
        --server = { path = "/opt/homebrew/bin/rust-analyzer" },
        assist = {
            importMergeBehavior = "last",
            importPrefix = "by_self",
        },
        files = {
            excludeDirs = { "target" }
        },
        workspace = {
            symbol = {
                search = {
                    limit = 3000
                }
            }
        },
        procMacro = {
            enable = true
        },
        diagnostics = {
            enable = true,
            disabled = { "unresolved-proc-macro" },
            enableExperimental = true,
            refreshSupport = false,
        },
        diagnostic = {
            refreshSupport = false,
        },
        check = {
            -- command = "clippy"
        },
        cargo = {
            features = "all",
            loadOutDirsFromCheck = true,
        }
    },
    gopls = {},
    pylsp = {},
    html = {},
    bashls = {},
    tailwindcss = {},
    htmx = {},
    lua_ls = {},
}

for server, config in pairs(servers) do
    lspconfig[server].setup(vim.tbl_extend("force", {
        on_attach = on_attach,
        capabilities = capabilities,
    }, config))
end

-- Configurazione di nvim-cmp per completamento
cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            else
                fallback()
            end
        end, { "i", "s" }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            else
                fallback()
            end
        end, { "i", "s" }),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<Return>'] = cmp.mapping.confirm({ select = false }),
    }),
    sources = {
        { name = 'nvim_lsp' },
    },
})

-- Diagnostica e aggiornamento visivo
vim.opt.updatetime = 1000
vim.cmd("highlight LspDiagnosticsLineNrWarning guifg=#E5C07B guibg=#4E4942 gui=bold")

vim.diagnostic.config({
    virtual_text = {
        prefix = "", -- Simbolo personalizzato
        format = function(_)
            return "!!"
        end,
    },
    float = {
        source = "always",
        focusable = false,
        border = "rounded",
    },
})

vim.api.nvim_create_autocmd('CursorHold', {
    callback = function()
        vim.diagnostic.open_float({ scope = 'line' })
    end
})


