#!/bin/bash
# Initialize dotfile symlinks.
# Usage: bash init_dot.sh [full|terminal]  (default: full)
set -e

PROFILE="${1:-full}"
DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

[[ -d "$DOT" ]] || { echo "dot_files not found at $DOT"; exit 1; }

mkdir -p "$HOME/.config"

link() {
    local src="$DOT/$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    echo "  $dst -> $src"
}

echo "profile: $PROFILE"

link "zsh_files/zsh_config"    "$HOME/.zshrc"
link "zsh_files/starship.toml" "$HOME/.config/starship.toml"
link "vim_files"               "$HOME/.config/nvim"

if [[ "$PROFILE" == "full" ]]; then
    link "ghostty_files"   "$HOME/.config/ghostty"
    link "niri_files"      "$HOME/.config/niri"
    link "noctalia_files"  "$HOME/.config/noctalia"
fi

echo "Done."
