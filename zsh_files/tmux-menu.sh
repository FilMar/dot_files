#!/usr/bin/env bash
set -uo pipefail

readonly RESURRECT=$HOME/.tmux/plugins/tmux-resurrect/scripts
readonly SAVE_LINK=$HOME/.local/share/tmux/resurrect/last
readonly CONF=$HOME/.config/tmux/tmux.conf
readonly HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly ACTIONS=(last window new rename close session ssh rename-session close-session copy save restore reload command)
declare -rA LABELS=(
    [last]="ultima finestra"
    [window]="vai a finestra"
    [new]="nuova finestra"
    [rename]="rinomina finestra"
    [close]="chiudi finestra"
    [session]="vai o crea sessione"
    [ssh]="connetti ssh"
    [rename-session]="rinomina sessione"
    [close-session]="chiudi sessione"
    [copy]="copy mode"
    [save]="salva"
    [restore]="ripristina"
    [reload]="ricarica config"
    [command]="comando tmux"
)
CLIENT=""

die() { printf '%s\n' "$1" >&2; exit 70; }
assert() { local -r msg=$1; shift; "$@" || die "$msg"; }

is_count() {
    assert "is_count: one argument" test $# -eq 1
    [[ $1 =~ ^[0-9]+$ ]] && (( 10#$1 >= 1 ))
}

is_flag() {
    assert "is_flag: one argument" test $# -eq 1
    [[ $1 == 0 || $1 == 1 ]]
}

is_index() {
    assert "is_index: one argument" test $# -eq 1
    [[ $1 =~ ^[0-9]+$ ]]
}

is_action() {
    assert "is_action: one argument" test $# -eq 1
    printf '%s\n' "${ACTIONS[@]}" | grep -qx -- "$1"
}

is_name() {
    assert "is_name: one argument" test $# -eq 1
    [[ -n $1 && $1 != *[\ :.]* ]]
}

no_session() {
    assert "no_session: one argument" test $# -eq 1
    ! tmux has-session -t "=$1"
}

visible_actions() {
    assert "visible_actions: windows is a count" is_count "$1"
    assert "visible_actions: sessions is a count" is_count "$2"
    assert "visible_actions: saved is 0 or 1" is_flag "$3"
    local result=""
    local -a visible=()
    local a
    for a in "${ACTIONS[@]}"; do
        case $a in
            last|window|close) (( 10#$1 > 1 )) || continue ;;
            close-session) (( 10#$2 > 1 )) || continue ;;
            restore) [[ $3 == 1 ]] || continue ;;
        esac
        visible+=("$a")
    done
    result=$(printf '%s\n' "${visible[@]}")
    assert "visible_actions: new always visible" grep -qx new <<<"$result"
    assert "visible_actions: command always visible" grep -qx command <<<"$result"
    printf '%s\n' "$result"
}

menu_lines() {
    local result=""
    local name line
    while IFS= read -r name; do
        [[ -n $name ]] || continue
        assert "menu_lines: label for $name" test -n "${LABELS[$name]:-}"
        printf -v line '%-15s %s\n' "$name" "${LABELS[$name]}"
        result+="$line"
    done
    result=${result%$'\n'}
    assert "menu_lines: one line per name" test -n "$result"
    printf '%s\n' "$result"
}

q() {
    assert "q: client known" test -n "$CLIENT"
    assert "q: format not empty" test -n "$1"
    tmux display -p -t "$CLIENT" "$1"
}

header() {
    local result=""
    result=$(q '#S  #{W:#{?window_active,[#W],#W} }')
    assert "header: not empty" test -n "$result"
    printf '%s\n' "$result"
}

pick() {
    assert "pick: prompt not empty" test -n "$1"
    local result=""
    if [[ -n ${2:-} ]]; then
        result=$(fzf --prompt "$1" --header "$2")
    else
        result=$(fzf --prompt "$1")
    fi
    [[ -n $result ]] || return 1
    printf '%s\n' "$result"
}

ask() {
    assert "ask: prompt not empty" test -n "$1"
    local result=""
    local -a lines=()
    mapfile -t lines < <(fzf --print-query --query "${2:-}")
    result=${lines[0]:-}
    [[ -n $result ]] || return 1
    printf '%s\n' "$result"
}

pick_or_type() {
    assert "pick_or_type: prompt not empty" test -n "$1"
    local result=""
    local -a lines=()
    mapfile -t lines < <(fzf --print-query)
    result=${lines[1]:-}
    [[ -n $result ]] || result=${lines[0]:-}
    [[ -n $result ]] || return 1
    printf '%s\n' "$result"
}

confirm() {
    assert "confirm: prompt not empty" test -n "$1"
    local answer=""
    answer=$(printf '%s\n' no "sì" | pick "$1")
    [[ $answer == "sì" ]]
}

act_last() {
    assert "act_last: more than one window" test "$(q '#{session_windows}')" -gt 1
    tmux last-window -t "$(q '#{session_id}')"
}

act_window() {
    local -r index=${1:-$(tmux list-windows -t "$(q '#{session_id}')" -F '#I  #W  #{pane_current_command}' | pick "finestra > " | cut -d' ' -f1)}
    [[ -n $index ]] || return 1
    assert "act_window: index is a number" is_index "$index"
    tmux select-window -t "$(q '#{session_id}'):$index"
    assert "act_window: window selected" test "$(q '#I')" = "$index"
}

act_new() {
    local -r before=$(q '#{session_windows}')
    tmux new-window -t "$(q '#{session_id}')" -c "$(q '#{pane_current_path}')"
    assert "act_new: one more window" test "$(q '#{session_windows}')" -eq $((before + 1))
}

act_rename() {
    local -r name=${1:-$(ask "nome > " "$(q '#W')")}
    [[ -n $name ]] || return 1
    tmux rename-window -t "$(q '#{window_id}')" "$name"
    assert "act_rename: name applied" test "$(q '#W')" = "$name"
}

act_close() {
    local -r before=$(q '#{session_windows}')
    assert "act_close: more than one window" test "$before" -gt 1
    tmux kill-window -t "$(q '#{window_id}')"
    assert "act_close: one window less" test "$(q '#{session_windows}')" -eq $((before - 1))
}

act_session() {
    local -r name=${1:-$(tmux list-sessions -F '#S' | pick_or_type "sessione > ")}
    [[ -n $name ]] || return 1
    assert "act_session: name is valid" is_name "$name"
    local -r dir=$(q '#{pane_current_path}')
    no_session "$name" && tmux new-session -d -s "$name" -c "$dir"
    tmux switch-client -c "$CLIENT" -t "=$name"
    assert "act_session: client on session" test "$(q '#S')" = "$name"
}

act_ssh() {
    assert "act_ssh: script exists" test -x "$HERE/tmux-ssh.sh"
    "$HERE/tmux-ssh.sh" "$@"
}

act_rename_session() {
    local -r name=${1:-$(ask "sessione > " "$(q '#S')")}
    [[ -n $name ]] || return 1
    assert "act_rename_session: name is valid" is_name "$name"
    tmux rename-session -t "$(q '#{session_id}')" "$name"
    assert "act_rename_session: name applied" test "$(q '#S')" = "$name"
}

act_close_session() {
    assert "act_close_session: another session exists" test "$(tmux list-sessions | wc -l)" -gt 1
    local -r name=$(q '#S')
    confirm "chiudere $name? " || return 1
    tmux switch-client -c "$CLIENT" -n
    tmux kill-session -t "=$name"
    assert "act_close_session: session gone" no_session "$name"
}

act_copy() {
    tmux copy-mode -t "$(q '#{pane_id}')"
    assert "act_copy: pane in copy mode" test "$(q '#{pane_in_mode}')" = 1
}

act_save() {
    assert "act_save: resurrect installed" test -x "$RESURRECT/save.sh"
    "$RESURRECT/save.sh"
    assert "act_save: save exists" test -e "$SAVE_LINK"
}

act_restore() {
    assert "act_restore: resurrect installed" test -x "$RESURRECT/restore.sh"
    assert "act_restore: save exists" test -e "$SAVE_LINK"
    "$RESURRECT/restore.sh"
}

act_reload() {
    assert "act_reload: config readable" test -r "$CONF"
    tmux source-file "$CONF"
}

act_command() {
    assert "act_command: client known" test -n "$CLIENT"
    tmux command-prompt -t "$CLIENT"
}

menu() {
    local -r windows=$(q '#{session_windows}')
    local -r sessions=$(tmux list-sessions | wc -l)
    local saved=0
    [[ -e $SAVE_LINK ]] && saved=1
    local -r name=$(visible_actions "$windows" "$sessions" "$saved" | menu_lines | pick "tmux > " "$(header)" | cut -d' ' -f1)
    [[ -n $name ]] || return 1
    assert "menu: chosen action is known" is_action "$name"
    "act_${name//-/_}"
}

main() {
    assert "main: inside tmux" test -n "${TMUX:-}"
    CLIENT=$(tmux display -p '#{client_name}')
    readonly CLIENT
    local -r name=${1:-menu}
    if [[ $name == menu ]]; then
        menu
    else
        assert "main: known action" is_action "$name"
        "act_${name//-/_}" "${@:2}"
    fi
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
