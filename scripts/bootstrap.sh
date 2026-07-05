#!/bin/bash
# Bootstrap a fresh Arch machine to the current system state.
# Idempotent: safe to re-run.
set -e

[[ $EUID -eq 0 ]] && { echo "run as normal user, not root"; exit 1; }

DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GIT_DIR="$(dirname "$DOT")"
PI="$GIT_DIR/pi"

# --- 1. packages (official repos) ---
sudo pacman -S --needed --noconfirm \
    niri ghostty sddm zsh starship neovim bun \
    podman podman-compose podman-docker \
    fzf git openssh curl base-devel

# --- 2. yay + AUR packages ---
if ! command -v yay &>/dev/null; then
    tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si --noconfirm)
fi
yay -S --needed --noconfirm \
    pi-coding-agent claude-code \
    noctalia-shell noctalia-qs \
    autojump-rs-bin megacmd-bin \
    catppuccin-cursors-mocha catppuccin-gtk-theme-mocha

# --- 3. SSH key (needed before any git@github.com clone) ---
SSH_KEY="$HOME/.ssh/id_ed25519"
if [[ ! -f "$SSH_KEY" ]]; then
    ssh-keygen -t ed25519 -f "$SSH_KEY" -N ""
fi
if [[ ! -d "$DOT" || ! -d "$PI" ]] && \
   ! ssh -o BatchMode=yes -o ConnectTimeout=5 -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo ""
    echo "Add this public key to GitHub (https://github.com/settings/keys):"
    echo ""
    cat "$SSH_KEY.pub"
    echo ""
    read -rp "Press enter once added to continue..."
fi

# --- 4. repos ---
mkdir -p "$GIT_DIR"
[[ -d "$DOT" ]] || git clone git@github.com:FilMar/dot_files.git "$DOT"
[[ -d "$PI"  ]] || git clone git@github.com:FilMar/alfred_ai_flow_manager.git "$PI"

# --- 5. oh-my-zsh + custom plugins ---
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
[[ -d "$HOME/.oh-my-zsh" ]] || \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
for p in zsh-autosuggestions zsh-syntax-highlighting; do
    [[ -d "$ZSH_CUSTOM/plugins/$p" ]] || git clone "https://github.com/zsh-users/$p" "$ZSH_CUSTOM/plugins/$p"
done
[[ -d "$ZSH_CUSTOM/plugins/fzf-tab" ]] || git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"

# --- 6. secrets stub (gitignored, filled by hand) ---
touch "$DOT/zsh_files/secret_env.sh"

# --- 7. dotfile symlinks ---
bash "$DOT/scripts/init_dot.sh" full

# --- 8. alfred: identity, skills, tb/th ---
bash "$PI/setup.sh"

# --- 9. system-level bits ---
sudo systemctl enable sddm
[[ "$SHELL" == "/usr/bin/zsh" ]] || sudo chsh -s /usr/bin/zsh "$USER"

echo ""
echo "Done. Manual steps left:"
echo "  - fill $DOT/zsh_files/secret_env.sh"
echo "  - auth: claude login, pi auth"
echo "  - MEGA sync (mega-login)"
echo "  - sddm theme (sddm_catpuccine in repo, not auto-installed)"
