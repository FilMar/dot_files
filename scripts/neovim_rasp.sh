#!/bin/bash
# Build and install (or update) neovim from source on Raspberry Pi OS.
# Keeps source in ~/build/neovim to reuse cmake cache on updates.
# Usage: bash neovim_rasp.sh
set -e

NVIM_SRC="$HOME/build/neovim"

sudo apt-get install -y git cmake build-essential

if [[ ! -d "$NVIM_SRC" ]]; then
    mkdir -p "$HOME/build"
    git clone --branch stable https://github.com/neovim/neovim.git "$NVIM_SRC"
else
    git -C "$NVIM_SRC" fetch origin stable
    LOCAL=$(git -C "$NVIM_SRC" rev-parse HEAD)
    REMOTE=$(git -C "$NVIM_SRC" rev-parse FETCH_HEAD)
    if [[ "$LOCAL" == "$REMOTE" ]]; then
        echo "Already up to date ($(nvim --version | head -1)). Nothing to do."
        exit 0
    fi
    git -C "$NVIM_SRC" checkout stable
    git -C "$NVIM_SRC" merge --ff-only origin/stable
fi

cmake -S "$NVIM_SRC" -B "$NVIM_SRC/build" -DCMAKE_BUILD_TYPE=Release -DUSE_BUNDLED_LUV=ON
cmake --build "$NVIM_SRC/build" -- -j"$(nproc)"

cd "$NVIM_SRC/build"
cpack -G DEB
deb=$(find . -name "nvim-linux*.deb" | head -1)
sudo dpkg -i --force-overwrite "$deb"

echo ""
echo "Installed: $(nvim --version | head -1)"
