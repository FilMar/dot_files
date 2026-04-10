vim.cmd.colorscheme("catppuccin-mocha")
if not vim.g.neovide then
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end
