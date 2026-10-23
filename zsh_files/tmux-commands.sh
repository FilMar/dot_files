#!/usr/bin/env bash
# tmux-commands.sh — telescope-like command palette over all tmux commands
# Trigger: prefix + P. Enter runs the selected command bare (default args).
# Destructive commands (kill-*) are excluded on purpose: they stay reachable
# only via the dedicated bindings (x, X) and the default < > menus.

tmp=$(mktemp /tmp/tmux-palette.XXXXXX)
tmux display-popup -E -w 62% -h 62% -T "tmux commands" \
    "tmux list-commands | grep -v '^kill-' | fzf --prompt='cmd > ' > '$tmp'"
sel=$(head -n1 "$tmp")
rm -f "$tmp"
[[ -n "$sel" ]] || exit 0
exec tmux "${sel%% *}"