vim.lsp.config.lean4 = {
  cmd = { "lean", "--server" },
  filetypes = { "lean" },
  root_markers = { "leanpkg.toml", "lean-toolchain", ".git" },
  settings = {
    lean = {
      -- Gestisce solo LSP, infoview gestita da lean.nvim
    },
  },
}

vim.lsp.enable("lean4")