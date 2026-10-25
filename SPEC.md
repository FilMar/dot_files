# Spec: tmux minimale con menu fzf

## Entità

- **tmux**
  - stato: sessioni, finestre, pane, client
  - fa: è l'unico proprietario dello stato; lo script lo legge e lo cambia solo con comandi tmux
  - non fa: barra di stato, prefix, split, tasti oltre a `M-Esc`
  - manda: sessione e finestra nel titolo del terminale (`set-titles`), che è il posto dove lo stato si legge senza aprire niente
  - comanda: l'utente, attraverso il menu

- **Contesto**
  - stato: numero di finestre, numero di sessioni, se esiste un salvataggio resurrect
  - fa: viene letto da tmux a ogni apertura del menu, mai tenuto in memoria
  - serve a: decidere quali voci compaiono

- **Voce**
  - stato: nome breve (per la shell) + etichetta in italiano (per il menu)
  - fa: una voce = un'azione = una funzione bash
  - lista: `last` ultima finestra, `window` vai a finestra, `new` nuova finestra, `rename` rinomina finestra, `close` chiudi finestra, `session` vai/crea sessione, `rename-session` rinomina sessione, `close-session` chiudi sessione, `copy` copy mode, `save` salva, `restore` ripristina, `reload` ricarica config, `command` comando tmux
  - visibili: `last`, `window`, `close` solo con più di una finestra; `close-session` solo con più di una sessione; `restore` solo se esiste un salvataggio; le altre sempre

- **Menu**
  - stato: nessuno
  - fa: popup fzf; header = sessione + finestre (la finestra attiva fra `[ ]`); voci nell'ordine della lista sopra, quindi `last` è la prima e `M-Esc Enter` torna all'ultima finestra
  - non fa: non mostra i tasti, non mostra i `list-commands`

- **Parametro**
  - fa: si risolve in quest'ordine: 1) argomento passato; 2) contesto (directory del pane, finestra o sessione corrente); 3) fzf: una lista da scegliere, oppure testo libero con `--print-query`
  - `rename` e `rename-session` partono dal nome attuale nella query
  - `session`: se scegli una voce ci vai, se scrivi un nome nuovo la crea
  - `close-session` chiede conferma `sì / no`; `close` no

## Flussi

- `M-Esc` → popup con il menu → voce scelta → azione sul client che ha premuto il tasto
- shell `tm` → menu nel terminale; `tm <voce> [arg]` → azione diretta, senza menu e senza domande se l'arg c'è
- `ts` = `tm session`, `tw` = `tm window`
- ESC in qualsiasi fzf → esce senza fare niente

## Invarianti

- un solo tasto tmux: `M-Esc`; nessun prefix
- nessuna barra di stato
- lo stato passivo (sessione, finestra) viaggia nel titolo del terminale: `'#S:#W'`; la tab del terminale fa da barra, senza pixel e senza tasti
- nessuna voce del menu senza etichetta: un nome che non ha etichetta ferma il menu con un errore, invece di stampare una riga vuota
- `C-h/j/k/l` arrivano sempre alla shell e alle app
- una voce sconosciuta (`tm boh`) è un errore di chi chiama: si ferma con un messaggio
- ESC o una scelta vuota non è un errore: nessuna azione, uscita silenziosa
- ogni azione agisce sul client di chi l'ha chiamata, anche se più terminali sono attaccati alla stessa sessione

## Fuori dallo scope

- resurrect + continuum restano come sono
- `M-Esc` non arriva più alle app (non risulta usato in nvim, niri, ghostty)
- da rimuovere: `tmux-commands.sh`, `tmux-keys.sh`, `tk`; `zsh_files/zsh/tmux-keys.sh` è una copia vecchia e morta, la rimuovo solo con il tuo ok

## Per i test (fatti che i contratti non dicono)

- file: `zsh_files/tmux-menu.test.sh`, bash semplice senza framework; carica lo script con `source` (il `main` non parte quando è caricato)
- ogni test è una funzione `test_*`; il file le trova con `declare -F`, le esegue ognuna in una subshell e stampa `ok` o `FAIL` per ognuna; exit 1 se almeno un test fallisce
- `expect_die "<messaggio>" <comando...>`: il comando deve uscire con codice 70 e lo stderr deve contenere il messaggio
- tmux isolato: il file definisce una funzione `tmux() { command tmux -L tmtest -f /dev/null "$@"; }` prima del `source`; crea le sessioni con `tmux new -d -s <nome> -x 80 -y 24`; un client vero si ottiene con `(script -qfc "tmux -L tmtest -f /dev/null attach -t <nome>" /dev/null >/dev/null 2>&1 &)` più `sleep 1`; `CLIENT` = `tmux list-clients -F '#{client_name}'`; alla fine `tmux kill-server`
- fzf non è interattivo nei test: il file definisce una funzione `fzf` finta che stampa righe decise dal test (per `--print-query`: prima riga = query, seconda = scelta)
- `act_save`, `act_restore`, `act_reload`, `act_command` non si testano: dipendono da resurrect, dalla config vera o dalla tastiera
- regole dei predicati:
  - `is_count`: intero ≥ 1, solo cifre
  - `is_flag`: esattamente `0` o `1`
  - `is_index`: intero ≥ 0, solo cifre
  - `is_action`: uno dei nomi in `ACTIONS`
  - `is_name`: non vuoto, senza `:`, `.` e spazi (tmux non li accetta nei nomi di sessione)
  - `no_session`: vero se `tmux has-session -t "=<nome>"` fallisce
- `visible_actions <finestre> <sessioni> <salvato>`: stampa i nomi nell'ordine di `ACTIONS`, uno per riga, applicando le regole di visibilità della sezione Voce. Tabella:
  - `1 1 0` → new rename session rename-session copy save reload command
  - `2 1 0` → last window new rename close session rename-session copy save reload command
  - `1 2 1` → new rename session rename-session close-session copy save restore reload command
  - `3 2 1` → tutte e 13
- `menu_lines`: legge nomi da stdin, stampa `printf '%-15s %s\n' <nome> <etichetta>` per ognuno; un nome senza etichetta in `LABELS` è un errore di chi chiama (exit 70, messaggio `menu_lines: label for <nome>`)
- `q <formato>`: `tmux display -p -t "$CLIENT" <formato>`
- `header`: `q '#S  #{W:#{?window_active,[#W],#W} }'`
- `pick <prompt> [header]`: fzf con `--prompt`, e `--header` se c'è; ESC o scelta vuota → return 1
- `ask <prompt> [query]`: fzf `--print-query --query`, input vuoto; risultato = prima riga (la query); ESC (exit 130) → return 1
- `pick_or_type <prompt>`: fzf `--print-query`; risultato = la scelta se c'è, altrimenti la query
- `confirm <prompt>`: `pick` su `no` e `sì`
- azioni: agiscono su sessione/finestra/pane del client, con target presi da `q` (`#{session_id}`, `#{window_id}`, `#{pane_id}`, `#{pane_current_path}`); `session` crea con `new-session -d -s <nome> -c <dir del pane>` se non esiste, poi `switch-client -c "$CLIENT" -t "=<nome>"`; `close-session` prima `switch-client -c "$CLIENT" -n`, poi `kill-session`
