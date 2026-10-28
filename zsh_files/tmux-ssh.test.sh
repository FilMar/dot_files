#!/usr/bin/env bash
set -uo pipefail

tmux() { command tmux -L sshtest -f /dev/null "$@"; }

getent() {
    [[ ${1:-} = hosts ]] || return 2
    case ${2:-} in
        loopback.example) printf '127.0.0.1 loopback.example\n' ;;
        later-loopback.example) printf '10.0.0.7 later-loopback.example\n127.0.0.1 later-loopback.example\n' ;;
        remote.example) printf '10.0.0.5 remote.example\n' ;;
        *) return 2 ;;
    esac
}

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

printf '#!/bin/sh\nexec sleep 60\n' >"$WORK/blocks"
chmod +x "$WORK/blocks"

SSH=$WORK/blocks
SSH_CONFIG=$WORK/config
EDITOR=$WORK/blocks
: >"$SSH_CONFIG"

source "$(dirname "${BASH_SOURCE[0]}")/tmux-ssh.sh"

ANSWERS=$WORK/answers
PROMPTS=$WORK/prompts
: >"$ANSWERS"
: >"$PROMPTS"

ask() {
    printf '%s\n' "$*" >>"$PROMPTS"
    local answer
    answer=$(head -n 1 "$ANSWERS" 2>/dev/null)
    sed -i '1d' "$ANSWERS" 2>/dev/null
    [[ -n $answer ]] || return 1
    printf '%s\n' "$answer"
}

PICK=""

pick_or_type() {
    printf '%s\n' "$*" >>"$PROMPTS"
    [[ -n $PICK ]] || return 1
    printf '%s\n' "$PICK"
}

answers() {
    : >"$ANSWERS"
    local a
    for a in "$@"; do
        printf '%s\n' "$a" >>"$ANSWERS"
    done
}

expect_die() {
    local -r msg=$1
    shift
    local err status
    err=$("$@" 2>&1 >/dev/null)
    status=$?
    [[ $status -eq 70 ]] || return 1
    [[ $err == *"$msg"* ]]
}

fails() {
    local status=0
    "$@" || status=$?
    [[ $status -ne 0 && $status -ne 70 ]]
}

quiet() {
    local -r want=$1
    shift
    local out err status
    out=$("$@" 2>"$WORK/err")
    status=$?
    [[ $status -eq $want ]] || return 1
    [[ -z $out && ! -s "$WORK/err" ]]
}

says() {
    local -r want=$1
    shift
    local out
    out=$("$@") || return 1
    [[ $out == "$want" ]]
}

windows() { tmux display -p -t "$CLIENT" '#{session_windows}'; }
current_window() { tmux display -p -t "$CLIENT" '#{window_id}'; }
has_window() { tmux list-windows -t "$(tmux display -p -t "$CLIENT" '#S')" -F '#W' | grep -qxF -- "$1"; }

test_no_pattern() {
    expect_die "no_pattern: one argument" no_pattern || return 1
    no_pattern abc || return 1
    fails no_pattern 'a*b' || return 1
    fails no_pattern 'a?b' || return 1
}

test_is_address() {
    expect_die "is_address: one argument" is_address || return 1
    is_address 'bob@10.0.0.5' || return 1
    fails is_address 'bob@' || return 1
    fails is_address '@host' || return 1
    fails is_address 'host' || return 1
}

test_is_loopback() {
    expect_die "is_loopback: one argument" is_loopback || return 1
    is_loopback loopback.example || return 1
    fails is_loopback later-loopback.example || return 1
    fails is_loopback remote.example || return 1
    fails is_loopback nothing.invalid || return 1
}

test_no_loopback() {
    expect_die "no_loopback: one argument" no_loopback || return 1
    fails no_loopback loopback.example || return 1
    no_loopback nothing.invalid || return 1
    no_loopback remote.example || return 1
}

test_hosts() {
    local -r file=$WORK/hosts
    expect_die "hosts: one argument" hosts || return 1
    expect_die "hosts: config readable" hosts "$WORK/missing" || return 1
    printf 'Host a b\nHost *.example\nHost re?al\nHost c # nota\n' >"$file"
    says $'a\nb\nc' hosts "$file" || return 1
    : >"$file"
    quiet 0 hosts "$file"
}

test_host_exists() {
    expect_die "host_exists: one argument" host_exists || return 1
    printf 'Host alpha\nHost beta\n' >"$SSH_CONFIG"
    host_exists alpha || return 1
    host_exists beta || return 1
    fails host_exists alph || return 1
    printf 'Host *\n' >"$SSH_CONFIG"
    fails host_exists '*'
}

test_block() {
    expect_die "block: three arguments" block alpha bob || return 1
    says $'Host alpha\n    HostName 10.0.0.5\n    User bob' block alpha bob 10.0.0.5
}

test_ask_address() {
    expect_die "ask_address: no arguments" ask_address x || return 1
    : >"$PROMPTS"
    answers ""
    quiet 1 ask_address || return 1
    : >"$PROMPTS"
    answers "bob@10.0.0.9"
    says "bob@10.0.0.9" ask_address || return 1
    [[ $(cat "$PROMPTS") == "utente@indirizzo > " ]] || return 1
    answers "nope"
    expect_die "ask_address: utente@indirizzo" ask_address || return 1
    answers "bob@loopback.example"
    expect_die "ask_address: not a loopback address" ask_address
}

test_register() {
    expect_die "register: three arguments" register alpha bob || return 1
    printf 'Host old\n' >"$SSH_CONFIG"
    register alpha bob 10.0.0.5 || return 1
    says $'Host old\n\nHost alpha\n    HostName 10.0.0.5\n    User bob' cat "$SSH_CONFIG" || return 1
    : >"$SSH_CONFIG"
    register alpha bob 10.0.0.5 || return 1
    says $'Host alpha\n    HostName 10.0.0.5\n    User bob' cat "$SSH_CONFIG" || return 1
    SSH_CONFIG=$WORK/nodir/config
    expect_die "register: config directory writable" register alpha bob 10.0.0.5 || return 1
    SSH_CONFIG=$WORK/config
    printf 'Host alpha\n' >"$SSH_CONFIG"
    host_exists alpha
}

test_connect() {
    expect_die "connect: one argument" connect || return 1
    expect_die "connect: alias valid for tmux" connect 'a.b' || return 1
    local before
    before=$(windows)
    connect alpha >/dev/null || return 1
    says "$SSH alpha" tmux display -p -t "$CLIENT" '#{pane_start_command}' || return 1
    tmux select-window -t "$CLIENT:^" || return 1
    connect alpha >/dev/null || return 1
    [[ $(windows) -eq $((before + 1)) ]]
}

test_edit_config() {
    local before
    SSH_CONFIG=$WORK/missing
    expect_die "edit_config: config exists" edit_config || return 1
    SSH_CONFIG=$WORK/config
    before=$(windows)
    edit_config || return 1
    [[ $(windows) -eq $((before + 1)) ]] || return 1
    says "$EDITOR $SSH_CONFIG" tmux display -p '#{pane_start_command}' || return 1
    tmux kill-window -t "$(current_window)"
    [[ $(windows) -eq $before ]]
}

test_add_host() {
    expect_die "add_host: at most one argument" add_host a b || return 1
    printf 'Host old\n' >"$SSH_CONFIG"
    answers ""
    quiet 1 add_host || return 1
    says 'Host old' cat "$SSH_CONFIG" || return 1
    answers "newhost" "bob@10.0.0.9"
    says "newhost" add_host || return 1
    host_exists newhost || return 1
    : >"$PROMPTS"
    answers "typed" "bob@10.0.0.9"
    says "typed" add_host suggested || return 1
    [[ $(head -n 1 "$PROMPTS") == "nome > "*suggested ]] || return 1
    answers "a.b" "bob@10.0.0.9"
    expect_die "add_host: alias valid for tmux" add_host
}

test_ssh_menu() {
    local before
    printf 'Host alpha\nHost newhost\n' >"$SSH_CONFIG"
    PICK=""
    quiet 0 ssh_menu || return 1
    has_window newhost && return 1
    : >"$PROMPTS"
    PICK=alpha
    ssh_menu >/dev/null || return 1
    has_window alpha || return 1
    [[ $(cat "$PROMPTS") == "host > " ]] || return 1
    PICK="$EDIT_LINE"
    before=$(windows)
    ssh_menu >/dev/null || return 1
    [[ $(windows) -eq $((before + 1)) ]] || return 1
    tmux kill-window -t "$(current_window)"
    PICK=fresh
    answers "fresh" "bob@10.0.0.7"
    ssh_menu >/dev/null || return 1
    host_exists fresh || return 1
    has_window fresh
}

test_ssh_main() {
    local -r tmux_env=${TMUX:-}
    TMUX=""
    expect_die "ssh_main: inside tmux" ssh_main || return 1
    TMUX=/tmp/sshtest-socket
    PICK=""
    ssh_main alpha >/dev/null || return 1
    has_window alpha || return 1
    [[ $(cat "$PROMPTS") != *"host > "* ]] || return 1
    TMUX=$tmux_env
}

tmux kill-server >/dev/null 2>&1 || true
tmux new -d -s alpha -x 80 -y 24
(script -qfc "tmux -L sshtest -f /dev/null attach -t alpha" /dev/null >/dev/null 2>&1 &)
sleep 1
CLIENT=$(tmux list-clients -F '#{client_name}')
if [[ -z $CLIENT ]]; then
    printf 'nessun client tmux\n' >&2
    tmux kill-server >/dev/null 2>&1 || true
    exit 1
fi

failed=0
while IFS= read -r fn; do
    status=0
    out=$("$fn" 2>&1) || status=$?
    if (( status )); then
        failed=1
        printf 'FAIL %s\n' "$fn"
        [[ -z $out ]] || printf '%s\n' "$out" | sed 's/^/    /'
    else
        printf 'ok %s\n' "$fn"
    fi
done < <(declare -F | awk '{print $3}' | grep '^test_')

tmux kill-server >/dev/null 2>&1 || true
exit "$failed"
