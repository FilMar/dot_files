# nix_files/home.nix
{ config, pkgs, lib, ... }:

let
  root      = ../.;                      # la cartella sopra nix_files
  hypr      = "${root}/hypr_files";
  zsh       = "${root}/zsh_files";
  nvim      = "${root}/vim_files";
  wezterm   = "${root}/wezterm_files";
in {
  home.username      = "filmar";
  home.homeDirectory = "/home/filmar";

  # 1) Hyprland
  home.file.".config/hypr/hyprland.conf".source =
    "${hypr}/hyprland.conf";

  # 2) Zsh
  programs.zsh.enable = true;
  home.file.".zshrc".source =
    "${zsh}/zshConfig";

  # 3) Neovim
  programs.neovim = {
    enable = true;
    vimrcConfigurable.customRC =
      builtins.readFile "${nvim}/init.lua";
  };

  # 4) WezTerm
  programs.wezterm.enable = true;
  programs.wezterm.extraConfig =
    builtins.readFile "${wezterm}/wezterm.lua";

  # 5) Variabili di sessione
  home.sessionVariables = {
    TERMINAL = "wezterm";
    BROWSER  = "brave";
  };
}
