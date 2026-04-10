require('blink.cmp').setup({
    keymap = {
        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-Space>'] = { 'show' },
    },
    appearance = {
        nerd_font_variant = 'mono',
    },
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    completion = {
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
        },
    },
})
