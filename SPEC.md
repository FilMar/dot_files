# Spec: ssh nel menu tmux

## Entità

- **Host**
  - stato: un blocco `Host <alias>` in `~/.ssh/config` — alias, `HostName`, `User`, più le opzioni scritte a mano
  - fa: è l'indirizzo con cui `ssh` sa come raggiungere una macchina
  - non fa: non viene mai copiato in un altro file; la lista si legge sempre da lì
  - comanda: ssh, con l'utente che scrive il file

- **Config** (`~/.ssh/config`, symlink a `ssh_files/config` nel repo)
  - stato: il testo dei blocchi `Host`
  - fa: è l'unica fonte degli host, e git ne registra ogni modifica
  - non fa: non contiene host inventati dal menu; il menu aggiunge solo quello che l'utente scrive
  - serve a: leggere la lista all'apertura del picker e ricevere i blocchi nuovi

- **Sessione ssh**
  - stato: il nome `ssh-<alias>`, posseduta da tmux come tutte le sessioni
  - fa: tiene viva la connessione quando chiudi il terminale; si riusa al secondo accesso
  - non fa: non torna come connessione dopo un riavvio — resurrect non ripristina `ssh` — quindi il nome dice cosa era
  - comanda: l'utente, dal menu

- **Picker**
  - stato: nessuno
  - fa: elenca gli alias di `~/.ssh/config` più una riga `modifica ssh config`; il testo libero è il nome di un host nuovo
  - non fa: non tiene una lista propria, non filtra per stato delle sessioni
  - serve a: scegliere una macchina senza sapere a memoria un tasto

## Flussi

- `M-Esc` → `ssh` → picker → host scelto → sessione `ssh-<alias>` (esiste: ci si entra; non esiste: `ssh <alias>` dentro) → client sul nuovo contesto
- picker → testo che non è un host → chiesto `nome`, chiesto `utente@indirizzo` → blocco appeso a `~/.ssh/config` → connessione come sopra
- picker → `modifica ssh config` → nvim sul file in una finestra nuova, non nel popup
- shell `tm ssh` → picker; `tm ssh <alias>` → connessione diretta, senza picker e senza domande

## Invarianti

- una sola voce in più nel menu, `ssh`, sempre visibile
- `~/.ssh/config` è l'unico proprietario degli host: la lista si legge dal file a ogni apertura
- una sessione per host, chiamata `ssh-<alias>`: se esiste si entra, non se ne crea una seconda
- un alias che tmux non accetta (spazi, `:`, `.`) si rifiuta con un messaggio, non si tronca né si trasforma
- l'indirizzo si scrive completo, `utente@indirizzo`: senza `@` la registrazione si ferma e mostra l'uso corretto
- un indirizzo che risolve a `127.0.0.1` viene rifiutato: è la risposta del router ai nomi che non conosce
- un indirizzo che non risolve affatto non è un errore: la macchina può essere spenta
- ESC o scelta vuota non scrivono niente e non creano niente, e chiudono il popup subito
- un contratto violato (uscita 70) lascia il messaggio leggibile nel popup finché non premi un tasto: ESC non è un errore, un assert sì
- ogni azione agisce sul client di chi l'ha chiamata, come nel resto del menu

## Fuori dallo scope

- niente `ControlMaster`, niente tunnel, niente `autossh`
- niente modifica o rimozione di host esistenti dal menu: si fa con l'editor, dalla riga `modifica ssh config`
- niente tasti dentro la connessione: `M-Esc` è locale e resta raggiungibile

## Struttura

- `zsh_files/tmux-menu.sh`: una voce `ssh` e `act_ssh`, che delega
- `zsh_files/tmux-ssh.sh`: picker, registrazione, guardia, creazione della sessione; carica `tmux-menu.sh` per i contratti condivisi, senza lanciarne il `main`
- `zsh_files/tmux-ssh.test.sh`: test propri; `ssh` e il percorso del config iniettabili, così la suite non apre connessioni né tocca il file vero

## Per i test (fatti che i contratti non dicono)

- `hosts <file>`: stampa un alias per riga, nell'ordine del file; `#` apre un commento fino a fine riga; salta `Host` con `*` o `?`; una riga `Host a b c` dà un alias per nome; se non resta niente non stampa nulla
- `no_pattern <testo>`: vero se `$testo` non contiene né `*` né `?`
- `is_address <testo>`: vero se c'è una `@` con qualcosa prima e dopo
- `is_loopback <indirizzo>`: vero se `getent hosts` risolve e il primo risultato è `127.0.0.1`; un indirizzo che non risolve dà falso
- `no_loopback <indirizzo>`: `is_loopback` negato, per l'assert
- `block <alias> <utente> <indirizzo>`: stampa il blocco a tre righe, indentato con quattro spazi: `Host <alias>`, `HostName <indirizzo>`, `User <utente>`
- `host_exists <alias>`: vero se `hosts "$SSH_CONFIG"` contiene quella riga esatta
- `register <alias> <utente> <indirizzo>`: se il file non è vuoto aggiunge una riga vuota, poi appende il blocco; dopo la scrittura l'alias è in `hosts`
- `ask_address`: nessun argomento; `ask "utente@indirizzo > "`; vuoto (ESC) → return 1 silenzioso, altrimenti il valore deve passare `is_address` con messaggio `ask_address: utente@indirizzo`
- `add_host [nome]`: chiede `nome > ` con `[nome]` come query; ESC sul nome → return 1 silenzioso; poi `ask_address`; registra e stampa l'alias
- `connect <alias>`: `tmux has-session -t "=ssh-<alias>"` → `switch-client`; altrimenti `new-session -d -s ssh-<alias> -c <dir del pane> $SSH <alias>`, poi `switch-client -c "$CLIENT"`; stampa il nome della sessione
- `edit_config`: `new-window -c <dir del pane> "${EDITOR:-nvim}" "$SSH_CONFIG"`
- `$SSH` vale `ssh` e `$SSH_CONFIG` vale `$HOME/.ssh/config` se non impostati **prima** del caricamento: è così che i test iniettano `true` e un file temporaneo
- `$EDITOR` si legge al momento della chiamata: i test lo mettono a `true`
- la riga `modifica ssh config` sta nella costante `EDIT_LINE`
- l'entry `ssh` di `ACTIONS` va dopo `session`, sempre fra le visibili
- `act_ssh` in `tmux-menu.sh` è solo una delega: `assert` che lo script esista, poi lo esegue con gli argomenti ricevuti. Il suo corpo è scritto a mano, non da un run
