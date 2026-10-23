#!/usr/bin/env bash
# tmux-menu.sh — dynamic key menu generated from the live prefix table
# Trigger: prefix + m (top menu). Submenus recurse: tmux-menu.sh <group>
# Item names come from bind-key -N notes; bindings without a note fall
# back to the command text. If a menu would not fit the client (tmux
# menus fail silently when taller than the terminal), falls back to
# the fzf browser (tmux-keys.sh) with an explanatory message.
# Usage:
#   tmux-menu.sh           top menu (groups)
#   tmux-menu.sh <group>   submenu: goto|windows|panes|resize|layout|copy|sessions|misc
#   tmux-menu.sh groups    diagnostic: item count per group

CONF="$HOME/.config/tmux"
GROUP="${1:-}"
PREFIX_KEY=$(tmux show-options -gv prefix)

# Catppuccin colors from tmux user options (set in tmux.conf)
BG=$(tmux show-options -gv @bg)
MAUVE=$(tmux show-options -gv @mauve)
SEL="fg=${BG:-#1e1e2e},bg=${MAUVE:-#cba6f7}"

order=(goto windows panes resize layout copy sessions misc)
declare -A GL GK
GL[goto]="Go to window"   GK[goto]=g
GL[windows]="Windows"    GK[windows]=w
GL[panes]="Panes"        GK[panes]=p
GL[resize]="Resize"      GK[resize]=r
GL[layout]="Layouts"     GK[layout]=l
GL[copy]="Copy & Paste"  GK[copy]=c
GL[sessions]="Sessions"  GK[sessions]=s
GL[misc]="More"          GK[misc]=o

# Group by command semantics, first match wins.
# split-window before window, select-window before window, pane after window.
group_of() {
    case "$1" in
        *resize-pane*)                                          echo resize ;;
        *layout*|*nextl*|*selectl*)                             echo layout ;;
        *split-window*)                                         echo panes ;;
        *select-window*)                                        echo goto ;;
        *choose-tree*-Zw*|*window*)                             echo windows ;;
        *pane*)                                                 echo panes ;;
        *buffer*|*copy*|*paste*)                                echo copy ;;
        *choose-tree*-Zs*|*session*|*client*|*detach*|*switch*) echo sessions ;;
        *)                                                       echo misc ;;
    esac
}

# key<TAB>note, only for bindings that have a note
declare -A NOTE
while IFS=$'\t' read -r k n; do
    NOTE[$k]="$n"
done < <(tmux list-keys -T prefix -N | awk -v pk="$PREFIX_KEY" '
    $1 == pk {
        key = $2; $1 = ""; $2 = ""; sub(/^ +/, "")
        printf "%s\t%s\n", key, $0
    }')

# group<TAB>key<TAB>name<TAB>cmd for the whole prefix table.
# Skips the menu itself (m) and the prefix key (send-prefix): a menu
# opened from inside a menu would just nest.
items=()
while IFS=$'\t' read -r k cmd; do
    [[ $k == m || $k == "$PREFIX_KEY" ]] && continue
    g=$(group_of "$cmd")
    name=${NOTE[$k]:-${cmd:0:28}}
    # list-keys escapes special keys (\{ \" \\%): menu keys must be raw
    [[ $k == \\* ]] && k=${k:1}
    items+=("$(printf '%s\t%s\t%s\t%s' "$g" "$k" "$name" "$cmd")")
done < <(tmux list-keys -T prefix | awk '
    /^bind-key[ \t]/ {
        line = $0
        sub(/^bind-key[ \t]+/, "", line)
        # strip leading flags (-r, ...) but not the -T table flag
        while (line ~ /^-/ && line !~ /^-T[ \t]/)
            sub(/^-[^ \t]+[ \t]+/, "", line)
        if (line !~ /^-T[ \t]+prefix[ \t]+/) next
        sub(/^-T[ \t]+prefix[ \t]+/, "", line)
        key = line; sub(/[ \t].*$/, "", key)
        cmd = line; sub(/^[^ \t]+[ \t]+/, "", cmd)
        printf "%s\t%s\n", key, cmd
    }')

count_of() {
    local c=0 it
    for it in "${items[@]}"; do [[ ${it%%$'\t'*} == "$1" ]] && c=$((c + 1)); done
    echo "$c"
}

if [[ $GROUP == groups ]]; then
    for it in "${items[@]}"; do
        IFS=$'\t' read -r g k name _ <<< "$it"
        printf '%-10s %-9s %s\n' "$g" "$k" "$name"
    done | sort
    exit 0
fi

# Height guard: a menu taller than the client fails silently in tmux
H=$(tmux display-message -p '#{client_height}' 2>/dev/null)
[[ $H =~ ^[0-9]+$ ]] || H=60

if [[ -z $GROUP ]]; then
    args=(-T "#[align=centre,bold]tmux keys" -H "$SEL")
    n=0
    for g in "${order[@]}"; do
        c=$(count_of "$g"); [[ $c -gt 0 ]] || continue
        args+=("+${GL[$g]}" "${GK[$g]}" "{ run-shell \"$CONF/tmux-menu.sh $g\" }")
        n=$((n + 1))
    done
else
    [[ -n ${GL[$GROUP]:-} ]] || { echo "unknown group: $GROUP" >&2; exit 1; }
    args=(-T "#[align=centre,bold]${GL[$GROUP]}" -H "$SEL")
    n=0
    for it in "${items[@]}"; do
        IFS=$'\t' read -r g k name cmd <<< "$it"
        [[ $g == "$GROUP" ]] || continue
        args+=("$name" "$k" "{ $cmd }")
        n=$((n + 1))
    done
fi

if [[ $n -eq 0 ]]; then
    tmux display-message "No bindings to show"
    exit 0
fi

if (( n + 5 > H )); then
    tmux display-message "Menu needs ~$((n + 5)) rows, client has $H — opening the fzf browser"
    exec "$CONF/tmux-keys.sh"
fi

exec tmux display-menu "${args[@]}"