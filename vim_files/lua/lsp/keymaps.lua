vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    if client.server_capabilities.completionProvider then
      vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    end

    if client.server_capabilities.definitionProvider then
      vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
    end

    client.server_capabilities.semanticTokensProvider = nil

    local keymap = vim.keymap.set
    local lsp = vim.lsp
    local bufopts = { noremap = true, silent = true }
    
    -- Core LSP mappings (tua style <leader>d*) with Telescope
    local telescope = require('telescope.builtin')
    
    bufopts.desc = "format file"
    keymap({ "n", "v" }, '<leader>df', lsp.buf.format, bufopts)
    bufopts.desc = "go to definition"
    keymap('n', '<leader>dd', telescope.lsp_definitions, bufopts)
    bufopts.desc = "show references"
    keymap('n', '<leader>dc', telescope.lsp_references, bufopts)
    bufopts.desc = "hover docs"
    keymap('n', '<leader>ds', function() lsp.buf.hover({ border = "single", max_height = 30, max_width = 120 }) end, bufopts)
    bufopts.desc = "diagnostic float"
    keymap('n', '<leader>de', vim.diagnostic.open_float, bufopts)
    
    -- Extended LSP mappings with Telescope
    bufopts.desc = "code action"
    keymap('n', '<leader>da', lsp.buf.code_action, bufopts)
    bufopts.desc = "rename symbol"
    keymap('n', '<leader>dr', lsp.buf.rename, bufopts)
    bufopts.desc = "go to implementation"
    keymap('n', '<leader>di', telescope.lsp_implementations, bufopts)
    bufopts.desc = "signature help"
    keymap('n', '<leader>dk', lsp.buf.signature_help, bufopts)
    bufopts.desc = "document symbols"
    keymap('n', '<leader>dl', telescope.lsp_document_symbols, bufopts)
    bufopts.desc = "workspace symbols"
    keymap('n', '<leader>dw', telescope.lsp_workspace_symbols, bufopts)
    
    -- Diagnostic navigation with Telescope
    bufopts.desc = "next diagnostic"
    keymap("n", "<Leader>dn", function() vim.diagnostic.jump({ count = 1, float = true }) end, bufopts)
    bufopts.desc = "prev diagnostic"
    keymap("n", "<Leader>dp", function() vim.diagnostic.jump({ count = -1, float = true }) end, bufopts)
    bufopts.desc = "diagnostic list (telescope)"
    keymap("n", "<Leader>dq", telescope.diagnostics, bufopts)
    
    -- LSP management
    bufopts.desc = "toggle inlay hints"
    keymap("n", "<Leader>dh", function() lsp.inlay_hint.enable(not lsp.inlay_hint.is_enabled({})) end, bufopts)
    bufopts.desc = "lsp info"
    keymap("n", "<Leader>dI", vim.cmd.LspInfo, bufopts)
    bufopts.desc = "mason"
    keymap("n", "<Leader>dM", vim.cmd.Mason, bufopts)
  end,
})
