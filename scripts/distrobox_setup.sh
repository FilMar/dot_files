#!/bin/bash
# Terminal-only provisioning for an Arch distrobox.
# Runs INSIDE the container, as the normal user (see distrobox.ini init_hooks).
# It's the shell/editor slice of bootstrap.sh, no GUI. Idempotent: safe to re-run.
set -e

[[ $EUID -eq 0 ]] && { echo "run as the normal user, not root"; exit 1; }

DOT="$HOME/projects/dot_files"

# --- 1. yay + AUR packages (exa and autojump are AUR-only on Arch) ---
if ! command -v yay &>/dev/null; then
    tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si --noconfirm)
fi
yay -S --needed --noconfirm exa autojump-rs-bin

# --- 2. oh-my-zsh + custom plugins ---
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
[[ -d "$HOME/.oh-my-zsh" ]] || \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
for p in zsh-autosuggestions zsh-syntax-highlighting; do
    [[ -d "$ZSH_CUSTOM/plugins/$p" ]] || git clone "https://github.com/zsh-users/$p" "$ZSH_CUSTOM/plugins/$p"
done
[[ -d "$ZSH_CUSTOM/plugins/fzf-tab" ]] || git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"

# --- 3. mise (activated by zsh_files/env.sh if present) ---
command -v mise &>/dev/null || [[ -x "$HOME/.local/bin/mise" ]] || curl -fsSL https://mise.run | sh

# --- 4. secrets stub (gitignored, filled by hand) ---
touch "$DOT/zsh_files/secret_env.sh"

# --- 5. dotfile symlinks (terminal profile: zsh + starship + nvim only) ---
bash "$DOT/scripts/init_dot.sh" terminal

# --- 6. default shell -> zsh ---
[[ "$(getent passwd "$USER" | cut -d: -f7)" == "/usr/bin/zsh" ]] || sudo chsh -s /usr/bin/zsh "$USER"

echo "distrobox terminal setup done"
