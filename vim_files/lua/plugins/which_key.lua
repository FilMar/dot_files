return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  priority = 100,
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
  config = function()
    local wk = require("which-key")
    wk.setup({
      delay = 300,
      preset = "modern",
    })
    
    -- ═══ GROUP LABELS ═══
    wk.add({
      { "<leader>f", group = "Find" },
      { "<leader>g", group = "Git" },
      { "<leader>d", group = "Diagnostics/LSP" },
      { "<leader>c", group = "Clipboard/Code" },
      { "<leader>b", group = "Buffers" },
      { "<leader>w", group = "Windows" },
      { "<leader>n", group = "Notes" },
      { "<leader>s", group = "Search/Replace" },
      { "<leader>L", group = "Lean" },
    })
    
    -- Force refresh dopo setup LSP
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function()
        -- Aspetta un momento e poi forza refresh
        vim.defer_fn(function()
          pcall(wk.register)
        end, 100)
      end,
    })
  end,
}
