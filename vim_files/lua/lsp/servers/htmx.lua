vim.lsp.config.htmx = {
  cmd = { "htmx-lsp" },
  filetypes = { "html", "templ", "htmldjango", "blade", "astro", "twig" },
  root_markers = { ".git" },
}

vim.lsp.enable("htmx")
