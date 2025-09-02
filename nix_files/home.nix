{ config, pkgs, ... }:

{
  home.username = "fildev";
  home.homeDirectory = "/home/fildev";
  
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Additional packages that can be installed system-wide or user-specific
  home.packages = with pkgs; [
    # System utilities
    git
    wget
    curl
    htop
    tree
    unzip
    zip
    
    # Development tools
    vim
    emacs
    obsidian
    
    # Media and graphics
    swww
    pavucontrol
    
    # Networking
    networkmanager
    
    # Applications
    firefox
    thunderbird
    mega-sync
    wired
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "fildev";
    userEmail = "your-email@example.com";  # Change this to your actual email
  };

  # Enable and configure services
  services = {
    # Add any services you need here
  };
}