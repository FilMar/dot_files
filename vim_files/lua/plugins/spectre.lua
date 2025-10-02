return {
  "nvim-pack/nvim-spectre",
  event = "VeryLazy",
  config = function()
    require("spectre").setup()
  end,
  -- Puoi aggiungere delle keymaps qui per un accesso rapido
  keys = {
    {"<leader>R", "<cmd>lua require('spectre').open()<CR>", desc = "Open Spectre"},
  },
}
