return {
  'Julian/lean.nvim',
  event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },

  dependencies = {
    'neovim/nvim-lspconfig',
    'nvim-lua/plenary.nvim',

    -- optional dependencies:

    -- a completion engine
    --    hrsh7th/nvim-cmp or Saghen/blink.cmp are popular choices

    -- 'nvim-telescope/telescope.nvim', -- for 2 Lean-specific pickers
    -- 'andymass/vim-matchup',          -- for enhanced % motion behavior
    -- 'andrewradev/switch.vim',        -- for switch support
    -- 'tomtom/tcomment_vim',           -- for commenting
  },

  ---@type lean.Config
  opts = {
    mappings = false, -- disabilita i mapping di default
    lsp = { enable = true }, -- lean.nvim gestisce tutto
    stderr = { enable = true },
    infoview = {
      autoopen = true,
      width = 50,
      height = 20,
    },
  },

  config = function(_, opts)
    require('lean').setup(opts)
    
    -- Keybinding personalizzati sotto <leader>L
    local keymap = vim.keymap.set
    local lean = require('lean')
    
    keymap('n', '<leader>Li', '<cmd>LeanInfoviewToggle<cr>', { desc = 'Toggle Lean infoview' })
    keymap('n', '<leader>Lr', '<cmd>LeanRestartServer<cr>', { desc = 'Restart Lean server' })
    keymap('n', '<leader>Ls', '<cmd>LeanGoalState<cr>', { desc = 'Show goal state' })
    keymap('n', '<leader>Lt', '<cmd>LeanTermGoal<cr>', { desc = 'Show term goal' })
    keymap('n', '<leader>Lp', '<cmd>LeanInfoviewPause<cr>', { desc = 'Pause infoview' })
    keymap('n', '<leader>Lu', '<cmd>LeanInfoviewUnpause<cr>', { desc = 'Unpause infoview' })
    keymap('n', '<leader>Lc', '<cmd>LeanInfoviewClear<cr>', { desc = 'Clear infoview' })
    keymap('n', '<leader>Lf', '<cmd>LeanInfoviewPinToggle<cr>', { desc = 'Toggle pin infoview' })
  end
}
