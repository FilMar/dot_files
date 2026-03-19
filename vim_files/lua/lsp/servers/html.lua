vim.lsp.config.html = {
  cmd = { "html-lsp" },
  filetypes = { "html", "templ", "htmldjango", "blade", "astro", "twig" },
  root_markers = { ".git" },
}

vim.lsp.enable("html")
