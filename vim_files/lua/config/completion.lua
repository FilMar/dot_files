local bli = require('blink.cmp')
bli.build():pwait()
bli.setup({
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
        per_filetype = {
            markdown = { 'duedates', 'lsp', 'path', 'snippets', 'buffer' },
        },
        providers = {
            duedates = { name = 'due', module = 'config.duedates' },
        },
    },
    completion = {
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
        },
    },
})

