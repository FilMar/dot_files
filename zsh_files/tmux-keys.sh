#!/usr/bin/env bash
# tmux-keys.sh — browse tmux keybindings with fzf
# Trigger: prefix + ? (inside tmux)

set -euo pipefail

list_keys() {
    local table="$1" label="$2"
    echo "── $label ──"
    tmux list-keys -T "$table" 2>/dev/null | awk -v OFS='|' '
        /^bind-key/ {
            key = $4
            cmd = ""
            for (i=5; i<=NF; i++) cmd = cmd $i " "
            if (key != "") printf "  %-12s| %s\n", key, cmd
        }'
    echo ""
}

{
    list_keys prefix "prefix keys (C-Esc + tasto)"
    list_keys root "no-prefix keys (diretti)"
    list_keys copy-mode-vi "copy mode keys (C-Esc + [ poi tasto)"
} | fzf \
    --prompt="tmux keys > " \
    --delimiter='|' \
    --with-nth='1,2' \
    --header="Enter: copia comando negli appunti tmux | ESC: esci" \
    --bind 'enter:execute(echo -n {2} | tmux load-buffer -)+abort'
