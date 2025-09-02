# NixOS Configuration

Questa cartella contiene la configurazione NixOS aggregata per tutti i dotfiles (eccetto neovim e zsh).

## Struttura

- `flake.nix` - Configurazione principale del flake con inputs e outputs
- `configuration.nix` - Configurazione sistema NixOS 
- `home.nix` - Configurazione Home Manager per l'utente
- `hyprland.nix` - Configurazione Hyprland window manager
- `waybar.nix` - Configurazione waybar status bar
- `wezterm.nix` - Configurazione terminale WezTerm
- `wofi.nix` - Configurazione launcher wofi

## Come usare

1. Copia i file nella tua configurazione NixOS (solitamente `/etc/nixos/`)
2. Modifica `configuration.nix` per adattarlo al tuo hardware
3. Aggiorna l'email in `home.nix` 
4. Ricostruisci il sistema: `sudo nixos-rebuild switch --flake .#nixos`

## Note

- La configurazione usa Home Manager per gestire le configurazioni utente
- Hyprland è integrato tramite il flake ufficiale
- I font necessari (FiraCode Nerd Font) sono inclusi automaticamente
- Le configurazioni di neovim e zsh sono escluse come richiesto