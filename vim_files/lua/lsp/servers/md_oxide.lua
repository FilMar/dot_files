vim.lsp.config.markdown_oxide = {
  cmd = { "markdown-oxide" },
  filetypes = { "markdown" },
  root_markers = { ".git", ".obsidian", "README.md" },
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
    textDocument = {
      hover = {
        dynamicRegistration = true,
        contentFormat = { "markdown", "plaintext" },
      },
      completion = {
        dynamicRegistration = true,
        completionItem = {
          snippetSupport = true,
        },
      },
    },
  },
}

vim.lsp.enable("markdown_oxide")
