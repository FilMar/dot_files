# Review: ssh nel menu tmux

## Esito

- Stato: in attesa del tuo giudizio
- 14 funzioni di test, 0 fallite nel file nuovo; 53 test, 0 falliti nel file del menu
- 19 mutanti su 19 uccisi
- il file dei test è stato riscritto nell'idioma che il repo già usava (`test_x()` con
  `return 1`, `expect_die`, `fails`, server tmux isolato con client vero): da 581 righe
  e 147 di framework privato a 284 righe e 45 di helper
- `bash -n` ok su tutti i file; `shellcheck` e `shfmt` non sono installati, come nel
  resto del repo

## Copertura della spec

| Contratto della spec | Dove |
|---|---|
| una voce in più, `ssh`, sempre visibile | `tmux-menu.sh` (`ACTIONS`, `LABELS`); nessun ramo in `visible_actions`, quindi sempre fra le visibili |
| la lista si legge dal file a ogni apertura | `ssh_menu` chiama `hosts "$SSH_CONFIG"` a ogni invocazione, nessuna cache |
| una sessione per host, `ssh-<alias>` | `connect`: `has-session -t "=ssh-<alias>"` prima di `new-session` |
| alias non valido per tmux → rifiuto con messaggio | `connect` e `add_host`, `is_name` |
| `utente@indirizzo`, senza `@` si ferma con l'uso | `ask_address`, messaggio `ask_address: utente@indirizzo` |
| un indirizzo che risolve a `127.0.0.1` viene rifiutato | `ask_address` (`no_loopback` sul pezzo dopo la `@`) |
| un indirizzo che non risolve non è un errore | `is_loopback` è falso quando `getent` non risolve, quindi `no_loopback` è vero |
| ESC non scrive e non crea | `ask_address` e `add_host` vuoti → return 1; `ssh_menu` → return 0 senza azione |
| l'azione agisce sul client di chi chiama | `connect` usa `$CLIENT` e `q`, ereditati da `tmux-menu.sh` |
| `modifica ssh config` in una finestra nuova | `edit_config`, `new-window -c <dir del pane>` con `${EDITOR:-nvim}` |

## Contratti `derive?`

Nessuno. Tre assert sono nati nel run dei corpi e non erano nella spec: il messaggio
`add_host: alias valid for tmux` compare sia nel corpo sia come postcondizione (il run
lo spiega: il corpo valida prima di chiedere l'indirizzo, la postcondizione resta come
rete di sicurezza), e `ask_address: not a loopback address` è il posto dove è finita la
guardia. Entrambi derivano da invarianti scritte in spec.

## Cosa ho corretto a mano, e perché

1. **`ssh_menu` usava `ask` invece di `pick_or_type`.** `ask` restituisce la query, non
   la scelta: scegliere un host con le frecce avrebbe dato stringa vuota e il menu
   sarebbe uscito senza fare niente. Corretto nei corpi; `check_body_diff.py` rieseguito
   contro la copia del todo, `ok: only todo lines were replaced`.
2. **Il picker passava per una pipe, con `pipefail` attivo.** Se il lettore chiude prima
   del produttore, la sostituzione torna 141 e `|| return 0` trasformava l'errore in un
   menu muto. Ora la lista passa da here-string, che non ha quel caso. Il guasto l'ha
   mostrato il test finto di `pick_or_type`, che non legge l'input: il picker vero lo
   legge, quindi in produzione non si vedeva, ma era una classe di guasti silenziosi.
3. **`readonly HERE` collideva** fra `tmux-menu.sh` e `tmux-ssh.sh`: al caricamento il
   secondo stampava `HERE: variabile in sola lettura` a ogni invocazione. Rinominato in
   `SSH_DIR`. Il difetto era mio, introdotto nel todo.
4. **`has-session` senza `2>/dev/null`**: alla prima connessione stampava
   `can't find session` dentro il popup, a ogni host nuovo.
5. Il run dei test ha prodotto tre difetti propri, corretti prima di usarlo: il path del
   modulo puntava a `../src/`, `run_suite` non veniva mai chiamato (il file non faceva
   niente), e c'erano tre stub morti di `assert`/`die`/`is_name` sovrascritti dal
   `source`.

## Test

- 14 funzioni, tutte verdi, in 284 righe. Helper: `expect_die`, `fails`, `quiet`,
  `says`, `answers`, più `ask`, `pick_or_type`, `getent` e il wrapper `tmux` isolato
- il tmux è vero: server su socket `sshtest`, client vero via `script`, sessioni vere.
  Si verificano lo stato reale (`list-windows`, `pane_start_command`, `session_windows`)
  invece di un registratore di chiamate. `SSH` ed `EDITOR` puntano a uno script che
  dorme, così la sessione e la finestra restano vive e la postcondizione è misurabile
- iniettati solo i confini: `getent` (DNS), `ask` e `pick_or_type` (tastiera). Le
  asserzioni sul testo dei prompt sono rimaste: la query passata a `ask` conta
- contro il todo: 50 precondizioni verdi, tutto il resto rosso
- mutanti, 19 su 19: `is_address` (at senza testo prima), `no_pattern` (senza `?`),
  `hosts` (patterns), `hosts` (commenti), `block` (utente e indirizzo scambiati),
  `register` (niente riga vuota), `register` (niente blocco), `connect` (senza
  prefisso), `connect` (senza `switch-client`), `connect` (ricrea sempre),
  `is_loopback` (ultima riga invece della prima), `edit_config` (EDITOR ignorato),
  `host_exists` (corrispondenza parziale), `add_host` (non registra), `add_host` (query
  non passata), `ask_address` (guardia loopback rimossa), `ssh_main` (argomento
  ignorato), `ssh_menu` (editor non aperto), `ssh_menu` (nome nuovo non registrato)

## Metriche

`contract_report.py` non riconosce bash ("no functions found"), come nel resto del repo.
Ricavate con awk:

```
functions=14 without_contract=0 max_logic_lines=17 (connect, add_host)
max_asserts per funzione=4 (connect)
comments=1 (solo lo shebang)
tmux-ssh.sh: 147 righe
tmux-ssh.test.sh: 284 righe (erano 581 prima della potatura)
tmux-menu.sh: 264 righe
tmux-menu.test.sh: 380 righe
```

## Cosa ha trovato la riscrittura dei test

I test vecchi, scritti contro un `tmux` finto che registrava le chiamate, non vedevano
tre difetti che i nuovi vedono:

1. `hosts` non tagliava i commenti: `Host c # nota` produceva anche `nota`, che sarebbe
   diventato un host fantasma nel picker. Corretto nei corpi: `#` apre un commento fino
   a fine riga.
2. `connect` chiamato su una sessione esistente stampava `duplicate session` a video,
   perché tmux rifiuta `new-session` con un nome già usato e il corpo non guardava
   l'errore. Non era idempotente nel rumore, solo nello stato.
3. Il rumore di `has-session` su una sessione assente (`can't find session`) finiva nel
   popup a ogni host nuovo.

## Errori di consegna, trovati dal vivo

Il primo `M-Esc → connetti ssh` non faceva niente. Due cause, entrambe mie:

1. `tmux-ssh.sh` non era symlinkato in `~/.config/tmux/`, che è la cartella da cui il
   popup lo cerca (`$HERE`);
2. non aveva il bit di esecuzione, quindi anche col symlink l'assert `act_ssh: script
   exists` avrebbe fallito.

Il messaggio dell'assert finiva in un popup che si chiude, quindi l'errore era
invisibile: da qui la seconda correzione, in `tmux.conf`:

```tmux
"~/.config/tmux/tmux-menu.sh; [ $? -eq 70 ] && read -r -n1 -s"
```

ESC in fzf esce con 1 e chiude come sempre; un contratto violato esce con 70 e il popup
aspetta un tasto. Il test `test_delegated_scripts_are_deployed` chiude il buco: estrae da
`tmux-menu.sh` ogni `$HERE/<nome>.sh`, e verifica che sia eseguibile nel repo e che
`init_dot.sh` lo linki. Provato a togliere la riga di link e a togliere il bit `x`:
fallisce in entrambi i casi.

## Scostamenti

- **`tmux-ssh.test.sh` è a 284 righe**, sotto le 350. `tmux-menu.test.sh` resta a 380,
  fuori misura da prima di questo lavoro.
- **`act_ssh` in `tmux-menu.sh` ha il corpo scritto a mano**, non da un run: è una
  delega di due righe con un solo assert (`act_ssh: script exists`). La procedura
  prevede due run per file, ma il file del menu ha già il suo test e il run dei test
  rifiuta di sovrascrivere un file esistente.
- **`register` aggiunge una riga vuota ogni volta che il file non è vuoto**, anche se
  finisce già con una riga vuota: due host aggiunti di fila lasciano una riga vuota in
  più. Innocuo per ssh, ma è una sbavatura di formato.
- **`connect` non verifica che la sessione esistente sia ancora una connessione viva.**
  Dopo un riavvio, resurrect può lasciare `ssh-<alias>` come shell locale: entrando ci
  si trova una shell, non ssh. È il motivo per cui il nome ha il prefisso; non c'è
  nessun controllo che lo distingua.

## Da provare dal vivo

Non fatto: `M-Esc → connetti ssh` su un terminale vero, con un host esistente e con uno
nuovo. I test usano `tmux` finto per le sessioni, quindi il primo giro vero può
riservare sorprese sulla creazione della finestra e sull'ambiente (PATH dentro la
sessione nuove, presenza di `ssh`).
