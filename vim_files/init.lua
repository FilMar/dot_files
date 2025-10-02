local vim = vim
-- show line number
vim.opt.relativenumber = true
vim.opt.nu = true
-- settting for tab
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
--activate mouse
vim.opt.mouse = 'a'
-- ignore upper and under case in search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.wrap = true
vim.opt.breakindent = true
--use spaces like tab
vim.opt.expandtab = true
--how long is tab
vim.opt.tabstop = 4
vim.opt.scrolloff = 25
-- set colorscheme
vim.opt.termguicolors = true
--vim.opt.colorcolumn = "80"
--fold settings
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldclose = "all"
--no_backup
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.config/nvim/.undodir"
-- set visible space
vim.opt.list = true
vim.opt.listchars = "tab:▸ ,trail:·,extends:❯,precedes:❮,space:·"

require("keybinds")
require("plugins")
require("lsp")
