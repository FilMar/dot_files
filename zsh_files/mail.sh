#!/bin/zsh
# Mail commands on top of himalaya.
#   mread  [account]               pick one of the last 100 mails, then an action
#   mread  [account] -s <query>    same, on a server search in INBOX
#   mwrite [account]               write a new mail in nvim, :wq sends, :q! aborts
# No account means the himalaya default account.
# Query: himalaya syntax, phrases need no quotes:
#   mread -s body grazie mille and from mario and not flag seen

_mail_hm() {
    local account=$1; shift
    himalaya ${account:+--account=$account} "$@"
}

# Quotes the words after from/to/subject/body up to and/or/order by.
# A query that already has double quotes passes through untouched.
_mail_query() {
    local q="$*"
    if [[ $q == *'"'* ]]; then
        print -r -- "$q"
        return
    fi
    local sort=''
    if [[ " $q " == *' order by '* ]]; then
        sort="order by ${q#* order by }"
        q=${q%% order by *}
    fi
    q=${q//\(/ ( }
    q=${q//\)/ ) }

    local -a out phrase
    local tok collecting=0
    for tok in ${=q}; do
        if (( collecting )) && [[ $tok != (and|or|\)) ]]; then
            phrase+=$tok
            continue
        fi
        if (( ${#phrase} )); then
            out+="\"${phrase[*]}\""
            phrase=()
        fi
        collecting=0
        [[ $tok == (from|to|subject|body) ]] && collecting=1
        out+=$tok
    done
    (( ${#phrase} )) && out+="\"${phrase[*]}\""
    q="${out[*]}"
    q=${q//\( /(}
    q=${q// \)/)}
    print -r -- "$q${sort:+ $sort}"
}

_mail_list() {
    local account=$1
    local query=$2
    local json
    if [[ -n $query ]]; then
        print -u2 'Searching...'
        json=$(_mail_hm "$account" envelope search --json -m INBOX -s 100 "$query")
    else
        json=$(_mail_hm "$account" envelope list --json -m INBOX -s 100)
    fi
    if ! jq -e '.envelopes' <<< "$json" > /dev/null 2>&1; then
        print -u2 -r -- "$(jq -r '.error // .' <<< "$json" 2>/dev/null || print -r -- "$json")"
        return 1
    fi
    jq -r '
        .envelopes[]
        | [ .id,
            (if any(.flags[]; .iana == "seen") then " " else "N" end),
            ((.date // "")[0:16] | sub("T"; " ")),
            (.from[0] | .name // .email // ""),
            .subject ]
        | @tsv' <<< "$json"
}

_mail_header() {
    sed -n "1,/^\$/s/^$2: *//p" "$1" | head -n 1
}

# kind: compose | reply | forward. id is empty for compose.
_mail_send() {
    local kind=${1:?_mail_send: kind required}
    local account=$2
    local id=$3
    [[ $kind == (compose|reply|forward) ]] || { print -u2 "_mail_send: unknown kind $kind"; return 1 }
    [[ $kind == compose || -n $id ]] || { print -u2 "_mail_send: id required for $kind"; return 1 }

    local dir=${XDG_CACHE_HOME:-$HOME/.cache}/mail-drafts
    mkdir -p "$dir"
    local draft=$dir/$(date +%Y%m%d-%H%M%S).eml
    local body=$draft.body
    print -l 'To: ' 'Cc: ' 'Subject: ' '' > "$draft"
    local before=$(md5sum < "$draft")
    nvim -c 'setfiletype mail' "$draft"

    if [[ $(md5sum < "$draft") == $before ]]; then
        rm -f "$draft"
        print 'Draft unchanged, nothing sent.'
        return 0
    fi

    local to=$(_mail_header "$draft" To)
    local cc=$(_mail_header "$draft" Cc)
    local subject=$(_mail_header "$draft" Subject)
    sed '1,/^$/d' "$draft" > "$body"

    if [[ $kind != reply && -z $to ]]; then
        print "No recipient, nothing sent. Draft kept: $draft"
        return 1
    fi

    local -a args=(--body-file "$body")
    [[ -n $to ]] && args+=(--to "$to")
    [[ -n $cc ]] && args+=(--cc "$cc")
    [[ -n $subject ]] && args+=(--subject "$subject")

    # TODO: no `--save <sent mailbox>` yet. Gmail stores sent mail by
    # itself; check the other accounts before adding it, or you get
    # duplicates.
    local -a cmd
    case $kind in
        compose) cmd=(message compose) ;;
        reply)   cmd=(message reply -m INBOX "$id") ;;
        forward) cmd=(message forward -m INBOX "$id") ;;
    esac

    if _mail_hm "$account" "${cmd[@]}" "${args[@]}" --send > /dev/null; then
        rm -f "$draft" "$body"
        print 'Sent.'
    else
        print "Send failed. Draft kept: $draft"
        return 1
    fi
}

mwrite() {
    _mail_send compose "$1"
}

# TODO: add an "attachments" action. `himalaya attachment list --json`
# gives id, filename and mime. `attachment download <msg> <att> --dir <d>
# --json` returns the saved path. Open PDF and EPUB with bookokrat. For
# other types, pick xdg-open or just print the path (xdg-open is a risk
# with untrusted files).
mread() {
    local account='' query=''
    if [[ -n $1 && $1 != (-s|--search) ]]; then
        account=$1
        shift
    fi
    if [[ $1 == (-s|--search) ]]; then
        shift
        (( $# )) || { print -u2 'mread: -s needs a query'; return 1 }
        query=$(_mail_query "$@")
    elif (( $# )); then
        print -u2 'usage: mread [account] [-s query]'
        return 1
    fi
    local preview="himalaya ${account:+--account=${(q)account}} message read -m INBOX {1}"

    local list
    list=$(_mail_list "$account" "$query") || return 1
    [[ -n $list ]] || { print 'No mail found.'; return 0 }

    local line=$(print -r -- "$list" | fzf \
        --delimiter '\t' --with-nth 2.. \
        --preview "$preview" --preview-window 'right,60%,wrap')
    [[ -n $line ]] || return 0
    local id=${line%%$'\t'*}

    local action=$(print -l read reply forward star delete | fzf --prompt 'action> ' --height 30% --reverse)
    case $action in
        read)    _mail_hm "$account" message read -m INBOX --seen "$id" | nvim -R -c 'setfiletype mail' - ;;
        reply)   _mail_send reply "$account" "$id" ;;
        forward) _mail_send forward "$account" "$id" ;;
        star)    _mail_hm "$account" flag add -m INBOX -f flagged "$id" > /dev/null && print 'Starred.' ;;
        delete)  read -q "?Delete message $id? [y/N] " && print && _mail_hm "$account" message delete -m INBOX "$id" > /dev/null && print 'Deleted.' ;;
    esac
}
