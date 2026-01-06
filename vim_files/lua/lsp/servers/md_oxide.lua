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
  },
}

vim.lsp.enable("markdown_oxide")
