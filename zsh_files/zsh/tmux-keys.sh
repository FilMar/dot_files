#!/usr/bin/env bash
# desc: Browse tmux prefix keybindings with fzf. Enter runs the selected command.
# usage: tmux-keys
set -euo pipefail

binds=$(tmux list-keys -T prefix 2>/dev/null | awk '
{
    key=""; cmd=""
    for(i=1; i<=NF; i++) {
        if($i == "-T" && $(i+1) == "prefix") {
            key = $(i+2)
            for(j=i+3; j<=NF; j++) {
                cmd = cmd (j>i+3 ? " " : "") $j
            }
            break
        }
    }
    sub(/^bind-key[ \t]+/, "", cmd)
    printf "%-6s %s\n", key, cmd
}')

selected=$(echo "$binds" | fzf \
    --prompt="tmux prefix > " \
    --preview='echo {2..}' \
    --preview-window=down:3 \
    --header="Enter: run command") || exit 0

[ -z "$selected" ] && exit 0

# extract command: everything after the key column
cmd=$(echo "$selected" | sed -E 's/^\S+[[:space:]]+//')

# shellcheck disable=SC2086
tmux $cmd
