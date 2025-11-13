vim.lsp.config.basedpyright = {
  name = "basedpyright",
  filetypes = { "python" },
  cmd = { "basedpyright-langserver", "--stdio" },
  settings = {
    python = {
      venvPath = ".",
      defaultInterpreter = "./.venv/bin/python",
    },
    basedpyright = {
      disableOrganizeImports = true,
      analysis = {
        autoSearchPaths = true,
        autoImportCompletions = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "strict",
        inlayHints = {
          variableTypes = true,
          callArgumentNames = true,
          functionReturnTypes = true,
          genericTypes = false,
        },
      },
    },
  },
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    local ok, venv = pcall(require, "rj.extras.venv")
    if ok then
      venv.setup()
    end
    local root = vim.fs.root(0, {
      ".venv",
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      "pyrightconfig.json",
      ".git",
      vim.uv.cwd(),
    })
    local client =
      vim.lsp.start(vim.tbl_extend("force", vim.lsp.config.basedpyright, { root_dir = root }), { attach = false })
    if client then
      vim.lsp.buf_attach_client(0, client)
    end
  end,
})

vim.api.nvim_create_user_command("PyrightConfig", function()
  local config_content = [[{
  "venvPath": ".",
  "venv": ".venv"
}
]]
  local file = io.open("pyrightconfig.json", "w")
  if file then
    file:write(config_content)
    file:close()
    vim.notify("pyrightconfig.json created in current directory")
  else
    vim.notify("Failed to create pyrightconfig.json", vim.log.levels.ERROR)
  end
end, {
  desc = "Create pyrightconfig.json in current directory",
})