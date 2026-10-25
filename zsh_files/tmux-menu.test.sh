#!/usr/bin/env bash
set -uo pipefail

tmux() { command tmux -L tmtest -f /dev/null "$@"; }

fzf() {
    local arg
    [[ ${FZF_STATUS:-0} -eq 0 ]] || return "$FZF_STATUS"
    for arg in "$@"; do
        if [[ $arg == "--print-query" ]]; then
            printf '%s\n' "$FZF_QUERY" "$FZF_CHOICE"
            return 0
        fi
    done
    printf '%s\n' "$FZF_CHOICE"
}

source "$(dirname "${BASH_SOURCE[0]}")/tmux-menu.sh"

FZF_QUERY=""
FZF_CHOICE=""
FZF_STATUS=0

expect_die() {
    local -r msg=$1
    shift
    local err status
    err=$("$@" 2>&1 >/dev/null)
    status=$?
    [[ $status -eq 70 ]] || return 1
    [[ $err == *"$msg"* ]] || return 1
}

fails() {
    local status=0
    "$@" || status=$?
    [[ $status -ne 0 && $status -ne 70 ]]
}

fresh() {
    tmux new -d -s "$1" -x 80 -y 24 || return 1
    tmux switch-client -c "$CLIENT" -t "=$1"
}

test_is_count_table() {
    is_count 1 || return 1
    is_count 2 || return 1
    fails is_count 0 || return 1
    fails is_count -1 || return 1
    fails is_count "" || return 1
    fails is_count 1a || return 1
}

test_is_count_two_args() {
    expect_die "is_count: one argument" is_count 1 2
}

test_is_flag_table() {
    is_flag 0 || return 1
    is_flag 1 || return 1
    fails is_flag 2 || return 1
    fails is_flag -1 || return 1
    fails is_flag "" || return 1
}

test_is_flag_two_args() {
    expect_die "is_flag: one argument" is_flag 0 1
}

test_is_index_table() {
    is_index 0 || return 1
    is_index 1 || return 1
    fails is_index -1 || return 1
    fails is_index "" || return 1
    fails is_index a || return 1
}

test_is_index_two_args() {
    expect_die "is_index: one argument" is_index 0 1
}

test_is_action_table() {
    local a
    for a in last window new rename close session rename-session close-session copy save restore reload command; do
        is_action "$a" || return 1
    done
    fails is_action boh || return 1
    fails is_action "" || return 1
    fails is_action menu || return 1
}

test_is_action_two_args() {
    expect_die "is_action: one argument" is_action last window
}

test_is_name_table() {
    is_name alpha || return 1
    is_name a || return 1
    is_name win-1 || return 1
    fails is_name "" || return 1
    fails is_name "a b" || return 1
    fails is_name "a:b" || return 1
    fails is_name "a.b" || return 1
}

test_is_name_two_args() {
    expect_die "is_name: one argument" is_name a b
}

test_no_session_two_args() {
    expect_die "no_session: one argument" no_session a b
}

test_no_session_table() {
    fresh presente || return 1
    fails no_session presente || return 1
    no_session presen || return 1
    no_session assente || return 1
}

test_visible_actions_windows_not_count() {
    expect_die "visible_actions: windows is a count" visible_actions x 1 0
}

test_visible_actions_sessions_not_count() {
    expect_die "visible_actions: sessions is a count" visible_actions 1 x 0
}

test_visible_actions_saved_not_flag() {
    expect_die "visible_actions: saved is 0 or 1" visible_actions 1 1 2
}

test_visible_actions_table() {
    [[ $(visible_actions 1 1 0) == "$(printf '%s\n' new rename session rename-session copy save reload command)" ]] || return 1
    [[ $(visible_actions 2 1 0) == "$(printf '%s\n' last window new rename close session rename-session copy save reload command)" ]] || return 1
    [[ $(visible_actions 1 2 1) == "$(printf '%s\n' new rename session rename-session close-session copy save restore reload command)" ]] || return 1
    [[ $(visible_actions 3 2 1) == "$(printf '%s\n' last window new rename close session rename-session close-session copy save restore reload command)" ]] || return 1
    [[ $(visible_actions 1 1 1) == "$(printf '%s\n' new rename session rename-session copy save restore reload command)" ]] || return 1
}

test_menu_lines_format() {
    local expected actual
    expected=$(printf '%-15s %s\n' \
        last "ultima finestra" \
        new "nuova finestra" \
        close "chiudi finestra" \
        save "salva" \
        rename-session "rinomina sessione" \
        command "comando tmux")
    actual=$(printf '%s\n' last new close save rename-session command | menu_lines)
    [[ $actual == "$expected" ]] || return 1
}

test_menu_lines_unknown_name_dies() {
    expect_die "menu_lines: label for boh" menu_lines <<< "boh"
}

test_q_without_client() {
    CLIENT=
    expect_die "q: client known" q '#S'
}

test_q_empty_format() {
    expect_die "q: format not empty" q ""
}

test_q_expands_format_on_client() {
    fresh qclient || return 1
    [[ $(q '#S') == "qclient" ]] || return 1
}

test_header_is_not_empty() {
    header >/dev/null
}

test_pick_empty_prompt() {
    expect_die "pick: prompt not empty" pick ""
}

test_pick_outcome() {
    FZF_CHOICE=new
    [[ $(pick "tmux > ") == "new" ]] || return 1
    FZF_CHOICE=
    fails pick "tmux > " || return 1
    FZF_STATUS=130
    fails pick "tmux > " || return 1
}

test_ask_empty_prompt() {
    expect_die "ask: prompt not empty" ask ""
}

test_ask_outcome() {
    FZF_QUERY=nuovo
    FZF_CHOICE=
    [[ $(ask "nome > " "vecchio") == "nuovo" ]] || return 1
    FZF_STATUS=130
    fails ask "nome > " "vecchio" || return 1
}

test_pick_or_type_empty_prompt() {
    expect_die "pick_or_type: prompt not empty" pick_or_type ""
}

test_pick_or_type_outcome() {
    FZF_QUERY=beta
    FZF_CHOICE=
    [[ $(pick_or_type "sessione > ") == "beta" ]] || return 1
    FZF_QUERY=gamma
    FZF_CHOICE=alpha
    [[ $(pick_or_type "sessione > ") == "alpha" ]] || return 1
}

test_confirm_empty_prompt() {
    expect_die "confirm: prompt not empty" confirm ""
}

test_confirm_outcome() {
    FZF_CHOICE="sì"
    confirm "chiudere? " || return 1
    FZF_CHOICE=no
    fails confirm "chiudere? " || return 1
}

test_act_last_one_window() {
    fresh unica || return 1
    expect_die "act_last: more than one window" act_last
}

test_act_last_two_windows() {
    fresh doppia || return 1
    tmux new-window -t doppia || return 1
    act_last
}

test_act_window_bad_index() {
    expect_die "act_window: index is a number" act_window -1
}

test_act_window_selects() {
    fresh scelta || return 1
    tmux new-window -d -t scelta || return 1
    local idx
    idx=$(tmux list-windows -t '=scelta' -F '#{window_active}#I' | grep '^0' | head -1 | cut -c2-)
    FZF_CHOICE="$idx  pannello  bash"
    act_window
}

test_act_new_adds_window() {
    fresh aggiunta || return 1
    act_new
}

test_act_rename_applies() {
    fresh rinomina || return 1
    act_rename ribattezzata
}

test_act_close_one_window() {
    fresh sola || return 1
    expect_die "act_close: more than one window" act_close
}

test_act_close_removes_window() {
    fresh chiusa || return 1
    tmux new-window -d -t chiusa || return 1
    act_close
}

test_act_session_bad_name() {
    expect_die "act_session: name is valid" act_session "a:b"
}

test_act_session_switches() {
    fresh partenza || return 1
    act_session nuova
}

test_act_rename_session_bad_name() {
    expect_die "act_rename_session: name is valid" act_rename_session "a b"
}

test_act_rename_session_applies() {
    fresh sessione || return 1
    act_rename_session rinnovata
}

test_act_close_session_alone() {
    local cur s
    local -a tutte
    cur=$(q '#S')
    mapfile -t tutte < <(tmux list-sessions -F '#S')
    for s in "${tutte[@]}"; do
        if [[ $s != "$cur" ]]; then
            tmux kill-session -t "=$s"
        fi
    done
    expect_die "act_close_session: another session exists" act_close_session
}

test_act_close_session_closes() {
    fresh condannata || return 1
    tmux new -d -s superstite -x 80 -y 24 || return 1
    FZF_CHOICE="sì"
    act_close_session
}

test_act_copy_enters_mode() {
    fresh copiata || return 1
    act_copy
}

test_menu_unknown_choice() {
    fresh scialba || return 1
    FZF_CHOICE=boh
    expect_die "menu: chosen action is known" menu
}

test_menu_acts() {
    fresh funzionante || return 1
    FZF_CHOICE=new
    menu
}

test_menu_esc_is_silent() {
    fresh fuggita || return 1
    FZF_STATUS=130
    fails menu || return 1
}

test_main_outside_tmux() {
    unset TMUX
    expect_die "main: inside tmux" main
}

test_main_unknown_action() {
    export TMUX=/tmp/tmtest,123,0
    expect_die "main: known action" main boh
}

test_main_direct_action() {
    export TMUX=/tmp/tmtest,123,0
    fresh diretta || return 1
    main new
}

test_main_menu_flow() {
    export TMUX=/tmp/tmtest,123,0
    fresh flusso || return 1
    FZF_CHOICE=new
    main
}

tmux kill-server >/dev/null 2>&1 || true
tmux new -d -s alpha -x 80 -y 24
(script -qfc "tmux -L tmtest -f /dev/null attach -t alpha" /dev/null >/dev/null 2>&1 &)
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
        if [[ -n $out ]]; then
            printf '%s\n' "$out" | sed 's/^/    /'
        fi
    else
        printf 'ok %s\n' "$fn"
    fi
done < <(declare -F | awk '{print $3}' | grep '^test_')

tmux kill-server >/dev/null 2>&1 || true
exit "$failed"