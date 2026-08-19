-- Faded grey + strikethrough for rejected tasks, grey taken from the theme
local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
vim.api.nvim_set_hl(0, "RenderMarkdownRejected", { fg = comment.fg, strikethrough = true })

require("render-markdown").setup({
    checkbox = {
        -- Plain ASCII everywhere: same width as the raw text, no icon glyphs.
        -- The state is carried by color, not by symbols.
        unchecked = { icon = "[ ]" },
        checked = { icon = "[x]" },
        custom = {
            in_progress = { raw = "[/]", rendered = "[/]", highlight = "DiagnosticInfo" },
            -- "todo" is the plugin builtin bound to [-]: override it as rejected
            todo = {
                raw = "[-]",
                rendered = "[-]",
                highlight = "RenderMarkdownRejected",
                scope_highlight = "RenderMarkdownRejected",
            },
        },
    },
})
