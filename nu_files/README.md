# Nushell Configuration

Configurazione Nushell convertita dalla configurazione zsh esistente.

## File

- `config.nu` - Configurazione principale di Nushell
- `aliases.nu` - Alias convertiti da zsh
- `functions.nu` - Funzioni convertite da zsh  
- `env.nu` - Configurazione ambiente e variabili
- `../nix_files/nushell.nix` - Configurazione Nix per Nushell

## Conversioni principali

### Da zsh a Nushell:
- ✅ Alias base convertiti
- ✅ Funzioni personalizzate convertite (warp, note, git workflow)
- ✅ Variabili ambiente (CONFIG_HOME, NOTES_HOME, etc.)
- ✅ Vi mode attivato
- ✅ History configurata (5000 entries)
- ✅ Prompt moderno con Starship (sostituisce typewritten)

### Miglioramenti:
- **Starship prompt** invece di typewritten theme
- **Syntax highlighting** built-in
- **Structured data** nativamente
- **Type safety** per comandi
- **Modern completions** con fuzzy matching

## Setup manuale

```bash
# Link config files
mkdir -p ~/.config/nushell
ln -sf $HOME/git_projects/dot_files/nu_files/config.nu ~/.config/nushell/config.nu
ln -sf $HOME/git_projects/dot_files/nu_files/env.nu ~/.config/nushell/env.nu

# Install starship for modern prompt
curl -sS https://starship.rs/install.sh | sh
```

## Note per la transizione

1. **Sintassi diversa** - Nushell usa pipe e structured data
2. **Alcune funzioni** potrebbero richiedere aggiustamenti manuali
3. **Virtual env** - gestione diversa da zsh/bash
4. **Plugin ecosystem** più moderno ma meno maturo di zsh