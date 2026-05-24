vim.lsp.config.tsserver = {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "typescript" },
  settings = {
  },
}

vim.lsp.enable("tsserver")
