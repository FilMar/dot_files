{ config, pkgs, ... }:

{
  # Ghostty configuration
  home-manager.users.fildev = {
    programs.ghostty = {
      enable = true;
      settings = {
        # Theme and appearance
        theme = "catppuccin-mocha";
        background-opacity = 0.9;
        
        # Font configuration  
        font-family = "FiraCode Nerd Font";
        font-size = 11;
        
        # Window settings
        window-decoration = true;
        window-theme = "dark";
        
        # Terminal behavior
        confirm-close-surface = false;
        copy-on-select = false;
        
        # Cursor
        cursor-style = "block";
        cursor-style-blink = false;
        
        # Shell integration
        shell-integration = "bash,zsh";
        
        # Scrollback
        scrollback-limit = 10000;
        
        # Mouse
        mouse-hide-while-typing = true;
        
        # Performance
        unfocused-split-opacity = 0.7;
      };
    };
  };

  # Required packages
  environment.systemPackages = with pkgs; [
    ghostty
  ];

  # Required fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];
}