local vim = vim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

local plugins = {
    -- theme
    require "plugins.catpuccine",
    -- which key
    require "plugins.which_key",
    -- LSP Config
    require "plugins.lsp",
    --telescope
    require "plugins.telescope",
    -- treesitter
    require "plugins.treesitter",
    --undotree
    require "plugins.undotree",
    --toggleterm
    require "plugins.toggle_term",
    -- statusbar
    require "plugins.lualine",
    -- todo comments
    require "plugins.todocomment",
    -- oil
    require "plugins.oil",
    -- rainbow-sql
    require "plugins.rainbowsql",
    -- neogit
    require "plugins.neogit",
    -- markdown render
    require "plugins.markdown",
    -- math render
    require "plugins.math",
    -- obsidian
    require "plugins.obsidian",
    -- sorrund
    require "plugins.surround",
    -- ai assistant
    require "plugins.ai",
    -- rustowl
    -- require "plugins.rustowl"
}
require("lazy").setup(plugins, opts)
