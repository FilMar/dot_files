# flake.nix
{
  description = "Flake NixOS con Home Manager per dotfiles (Hyprland, Zsh, Neovim, WezTerm)";

  inputs = {
    nixpkgs.url        = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url    = "github:numtide/flake-utils";
    home-manager.url   = "github:nix-community/home-manager/release-24.05";
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, ... }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
      lib = pkgs.lib;
    in {
      # Sistema NixOS
      nixosConfigurations.myhost = pkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./nixos/configuration.nix
          ./nixos/hardware-configuration.nix
          home-manager.nixosModules.home-manager
        ];
        specialArgs = { inherit lib; };
      };

      # Home Manager per “filmar”
      homeConfigurations.filmar = home-manager.lib.homeManagerConfiguration {
        inherit system;
        username      = "filmar";
        homeDirectory = "/home/filmar";
        configuration = ./home.nix;
      };
    });
}
