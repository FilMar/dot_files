#!/usr/bin/env bash
set -uo pipefail

readonly SSH_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly EDIT_LINE="modifica ssh config"

source "$SSH_DIR/tmux-menu.sh"

SSH=${SSH:-ssh}
SSH_CONFIG=${SSH_CONFIG:-$HOME/.ssh/config}

no_pattern() {
    assert "no_pattern: one argument" test $# -eq 1
    ! grep -q -- '[*?]' <<<"$1"
}

is_address() {
    assert "is_address: one argument" test $# -eq 1
    [[ $1 == ?*@?* ]]
}

is_loopback() {
    assert "is_loopback: one argument" test $# -eq 1
    local line
    line=$(getent hosts "$1" 2>/dev/null | head -n 1)
    [[ ${line%%[[:space:]]*} == "127.0.0.1" ]]
}

no_loopback() {
    assert "no_loopback: one argument" test $# -eq 1
    ! is_loopback "$1"
}

hosts() {
    assert "hosts: one argument" test $# -eq 1
    assert "hosts: config readable" test -r "$1"
    local result=""
    result=$(awk '{ sub(/#.*/, "") } $1 == "Host" { for (i = 2; i <= NF; ++i) if ($i !~ /[*?]/) print $i }' "$1")
    assert "hosts: no alias is a pattern" no_pattern "$result"
    [[ -z $result ]] || printf '%s\n' "$result"
}

host_exists() {
    assert "host_exists: one argument" test $# -eq 1
    hosts "$SSH_CONFIG" | grep -xF -- "$1" >/dev/null
}

block() {
    assert "block: three arguments" test $# -eq 3
    local result=""
    printf -v result 'Host %s\n    HostName %s\n    User %s' "$1" "$3" "$2"
    assert "block: starts with the alias" test "${result%%$'\n'*}" = "Host $1"
    printf '%s\n' "$result"
}

ask_address() {
    assert "ask_address: no arguments" test $# -eq 0
    local result=""
    result=$(ask "utente@indirizzo > ")
    if is_address "$result"; then
        assert "ask_address: not a loopback address" no_loopback "${result#*@}"
    fi
    [[ -n $result ]] || return 1
    assert "ask_address: utente@indirizzo" is_address "$result"
    printf '%s\n' "$result"
}

register() {
    assert "register: three arguments" test $# -eq 3
    assert "register: config directory writable" test -w "$(dirname "$SSH_CONFIG")"
    if [[ -s $SSH_CONFIG ]]; then
        printf '\n' >>"$SSH_CONFIG"
    fi
    block "$1" "$2" "$3" >>"$SSH_CONFIG"
    assert "register: alias listed" host_exists "$1"
}

connect() {
    assert "connect: one argument" test $# -eq 1
    assert "connect: alias valid for tmux" is_name "$1"
    assert "connect: client known" test -n "${CLIENT:-}"
    local result=""
    local -r session="ssh-$1"
    result=$session
    if tmux has-session -t "=$session" 2>/dev/null; then
        tmux switch-client -c "$CLIENT" -t "=$session"
    else
        tmux new-session -d -s "$session" -c "$(q '#{pane_current_path}')" "$SSH" "$1"
        tmux switch-client -c "$CLIENT" -t "=$session"
    fi
    assert "connect: client on session" test "$(q '#S')" = "$result"
    printf '%s\n' "$result"
}

edit_config() {
    assert "edit_config: config exists" test -e "$SSH_CONFIG"
    local -r before=$(q '#{session_windows}')
    tmux new-window -c "$(q '#{pane_current_path}')" "${EDITOR:-nvim}" "$SSH_CONFIG"
    assert "edit_config: one more window" test "$(q '#{session_windows}')" -eq $((before + 1))
}

add_host() {
    assert "add_host: at most one argument" test $# -le 1
    local result=""
    local name address
    name=$(ask "nome > " "${1:-}")
    if [[ -n $name ]]; then
        assert "add_host: alias valid for tmux" is_name "$name"
        if address=$(ask_address); then
            register "$name" "${address%%@*}" "${address#*@}"
            result=$name
        fi
    fi
    [[ -n $result ]] || return 1
    assert "add_host: alias valid for tmux" is_name "$result"
    printf '%s\n' "$result"
}

ssh_menu() {
    assert "ssh_menu: client known" test -n "${CLIENT:-}"
    local choice name list
    list=$({ hosts "$SSH_CONFIG"; printf '%s\n' "$EDIT_LINE"; })
    choice=$(pick_or_type "host > " <<<"$list") || return 0
    if [[ $choice == "$EDIT_LINE" ]]; then
        edit_config
    elif host_exists "$choice"; then
        connect "$choice"
    elif name=$(add_host "$choice"); then
        connect "$name"
    fi
}

ssh_main() {
    assert "ssh_main: inside tmux" test -n "${TMUX:-}"
    if [[ -z ${CLIENT:-} ]]; then
        CLIENT=$(tmux display -p '#{client_name}')
    fi
    assert "ssh_main: client known" test -n "$CLIENT"
    local -r alias=${1:-}
    if [[ -n $alias ]]; then
        connect "$alias"
    else
        ssh_menu
    fi
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && ssh_main "$@"
