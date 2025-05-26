# nixos/configuration.nix
{ config, pkgs, ... }:

let
  # Overlay per Hyprland e Fuzzel
  hyprPkgs = import <nixpkgs> {
    overlays = [ (self: super: {
      hyprland = super.hyprland;
      fuzzel   = super.fuzzel;     # launcher Wayland fuzzel
    }) ];
  };
in {
  networking.hostName = "myhost";
  time.timeZone       = "Europe/Rome";
  i18n.defaultLocale  = "it_IT.UTF-8";
  console.keyMap      = "us";

  users.users.filmar = {
    isNormalUser = true;
    extraGroups  = [ "wheel" "networkmanager" "docker" ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA…tuachiave… commento" ];
    shell = pkgs.zsh;
  };

  security.sudo.enable           = true;
  security.sudo.wheelNeedsPassword = false;

  programs.zsh = {
    enable               = true;
    interactiveShellInit = ''
      [[ -f ~/.zshrc ]] && source ~/.zshrc
    '';
    ohMyZsh.enable  = true;
    ohMyZsh.theme   = "robbyrussell";
    ohMyZsh.plugins = [ "git" "docker" ];
  };

  services.openssh.enable          = true;
  networking.networkmanager.enable = true;
  networking.firewall.enable       = true;

  services.xserver.enable   = false;
  services.hyprland.enable  = true;

  virtualisation.podman.enable = true;

  services.journald.enable   = true;
  services.journald.settings = {
    SystemMaxUse  = "200M";
    RuntimeMaxUse = "100M";
  };
  services.logrotate.enable = true;

  environment.systemPackages = with pkgs; [
    brave
    git
    curl
    wget

    hyprPkgs.hyprland
    hyprPkgs.fuzzel    # launch con fuzzel
    wezterm

    podman
    podman-docker
  ];

  system.stateVersion = "24.05";
}
