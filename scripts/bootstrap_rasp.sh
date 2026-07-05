#!/bin/bash
# Bootstrap a Raspberry Pi OS (arm64) machine — terminal stack only.
# Idempotent: safe to re-run.
# Usage: bash bootstrap_rasp.sh [--with-podman]
set -e

[[ $EUID -eq 0 ]] && { echo "run as normal user, not root"; exit 1; }

WITH_PODMAN=0
for arg in "$@"; do [[ "$arg" == "--with-podman" ]] && WITH_PODMAN=1; done

DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# --- 1. apt packages ---
sudo apt-get update -qq
sudo apt-get install -y \
    zsh fzf git curl build-essential cmake \
    autojump openssh-client \
    fd-find ripgrep python3-pip

[[ $WITH_PODMAN -eq 1 ]] && sudo apt-get install -y podman

# --- 2. neovim (build from source — apt version is too old) ---
bash "$DOT/scripts/neovim_rasp.sh"

# --- 3. starship ---
if ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# --- 4. bun ---
if ! command -v bun &>/dev/null; then
    curl -fsSL https://bun.sh/install | bash
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
fi

# --- 5. pi ---
if ! command -v pi &>/dev/null; then
    curl -fsSL https://pi.dev/install.sh | sh
fi

# --- 7. SSH key ---
SSH_KEY="$HOME/.ssh/id_ed25519"
if [[ ! -f "$SSH_KEY" ]]; then
    ssh-keygen -t ed25519 -f "$SSH_KEY" -N ""
fi
if [[ ! -d "$DOT" ]] && \
   ! ssh -o BatchMode=yes -o ConnectTimeout=5 -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo ""
    echo "Add this public key to GitHub (https://github.com/settings/keys):"
    echo ""
    cat "$SSH_KEY.pub"
    echo ""
    read -rp "Press enter once added to continue..."
fi

# --- 8. dot_files repo ---
mkdir -p "$GIT_DIR"
[[ -d "$DOT" ]] || git clone git@github.com:FilMar/dot_files.git "$DOT"

# --- 9. oh-my-zsh + plugins ---
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
[[ -d "$HOME/.oh-my-zsh" ]] || \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
for p in zsh-autosuggestions zsh-syntax-highlighting; do
    [[ -d "$ZSH_CUSTOM/plugins/$p" ]] || \
        git clone "https://github.com/zsh-users/$p" "$ZSH_CUSTOM/plugins/$p"
done
[[ -d "$ZSH_CUSTOM/plugins/fzf-tab" ]] || \
    git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"

# --- 10. secrets stub ---
touch "$DOT/zsh_files/secret_env.sh"

# --- 11. dotfile symlinks ---
bash "$DOT/scripts/init_dot.sh" terminal

# --- 12. zsh as default shell ---
[[ "$SHELL" == "/usr/bin/zsh" ]] || sudo chsh -s /usr/bin/zsh "$USER"

echo ""
echo "Done. Manual steps left:"
echo "  - fill $DOT/zsh_files/secret_env.sh"
echo "  - auth: pi auth"
[[ $WITH_PODMAN -eq 1 ]] && echo "  - podman: verify with 'podman run hello-world'"
