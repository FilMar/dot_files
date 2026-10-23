#!/usr/bin/env bash
# tmux-keys.sh — browse tmux keybindings with fzf
# Trigger: prefix + ? (inside tmux)
# Runs in a centered popup: run-shell jobs have no tty and fzf needs
# one for interaction. Enter copies the command to the tmux paste
# buffer (runs inside the popup), ESC closes.

set -euo pipefail

list=$(mktemp /tmp/tmux-keys.list.XXXXXX)

list_keys() {
    local table="$1" label="$2"
    echo "── $label ──"
    # strip flags (-r, ...) but not -T, then table, then key and command
    tmux list-keys -T "$table" 2>/dev/null | awk '
        /^bind-key[ \t]/ {
            line = $0
            sub(/^bind-key[ \t]+/, "", line)
            while (line ~ /^-/ && line !~ /^-T[ \t]/)
                sub(/^-[^ \t]+[ \t]+/, "", line)
            if (line !~ /^-T[ \t]+[^ \t]+[ \t]+/) next
            sub(/^-T[ \t]+[^ \t]+[ \t]+/, "", line)
            key = line; sub(/[ \t].*$/, "", key)
            cmd = line; sub(/^[^ \t]+[ \t]+/, "", cmd)
            printf "  %-12s|%s\n", key, cmd
        }'
    echo ""
}

{
    list_keys prefix "prefix keys (M-Esc + tasto)"
    list_keys root "no-prefix keys (diretti)"
    list_keys copy-mode-vi "copy mode keys (M-Esc + [ poi tasto)"
} > "$list"

# display-popup returns fzf's exit code (130 on ESC): don't let
# set -e skip the cleanup below
tmux display-popup -E -w 62% -h 62% -T "tmux keys" \
    "fzf --prompt='tmux keys > ' --delimiter='|' --with-nth='1,2' \
     --header='Enter: copia comando negli appunti tmux | ESC: esci' \
     --bind 'enter:execute(echo -n {2} | tmux load-buffer -)+abort' \
     < '$list' > /dev/null" || true

rm -f "$list"