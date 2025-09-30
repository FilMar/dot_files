vim.lsp.config.lean4 = {
  cmd = { "lean", "--server" },
  filetypes = { "lean" },
  root_markers = { "leanpkg.toml", "lean-toolchain", ".git", vim.uv.cwd() },
  settings = {
    lean = {
      -- Disabilita il LSP di lean.nvim se preferisci usare solo questo
      lsp = { enable = true },
    },
  },
}

vim.lsp.enable("lean4")