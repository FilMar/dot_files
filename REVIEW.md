# Review: tmux minimale con menu fzf

## Esito

- Stato: approvato
- giro 1: 51/51 test, 15/15 mutanti uccisi; manca la prova dal vivo sul client vero
- giro 2: approvato dall'utente; i ritocchi suoi allo stile del popup sono inclusi, i test ripassati 51/51 e la config passa il parsing; file di test lasciato a 376 righe
- giro 3 (due fix dopo la review del menu): lo stato passivo va nel titolo del terminale, e `menu_lines` rifiuta un nome senza etichetta. 52/52 test, 0 falliti. Approvato dall'utente

## Copertura della spec

- un solo tasto `M-Esc`, nessun prefix → `zsh_files/tmux.conf` (`set -g prefix None`, `bind -n M-Escape display-popup ...`)
- nessuna barra → `tmux.conf` (`set -g status off`)
- `C-h/j/k/l` liberi → `tmux.conf` (rimosso lo smart switching)
- Contesto letto ogni volta → `tmux-menu.sh: menu` (`q`, `tmux list-sessions`, `SAVE_LINK`)
- Voci e visibilità → `ACTIONS`, `LABELS`, `visible_actions`
- Menu con header sessione + finestre → `menu`, `header`, `menu_lines`, `pick`
- Parametro: argomento → contesto → fzf → `${1:-$(ask ...)}` in `act_rename`, `act_rename_session`, `act_session`, `act_window`
- `session` vai o crea → `act_session` + `pick_or_type`
- conferma su `close-session` → `confirm`
- shell `tm`, `ts`, `tw` → `zsh_files/zsh/zsh-basic`
- ESC = uscita silenziosa → `[[ -n $result ]] || return 1` in `pick`, `ask`, `pick_or_type`
- voce sconosciuta = errore → `main: known action`, `menu: chosen action is known`
- azione sul client di chi chiama → `CLIENT` + `q` con `-t "$CLIENT"`, `switch-client -c "$CLIENT"`
- stato passivo nel titolo del terminale → `tmux.conf` (`set-titles on`, `set-titles-string '#S:#W'`), niente barra
- nessuna voce senza etichetta → `menu_lines` (`assert "menu_lines: label for $name"`)

## Contratti derive?

| Contratto | Derivato da | Principio |
|---|---|---|
| `is_*: one argument` su ogni predicato | regola "ogni funzione ha un contratto"; la spec non dice niente sull'arità | P2 |
| `act_save: resurrect installed`, `act_restore: resurrect installed` | dipendenza esterna, non nella spec | P2 |
| `act_reload: config readable` | dipendenza esterna, non nella spec | P2 |
| `menu_lines: label for <nome>` | invariante scritto in spec al giro 3 (nessuna voce senza etichetta) | P2 |

## Metriche

`contract_report.py` non riconosce bash ("No functions found"). Ho ricavato le stesse metriche con un awk:

```
functions=31 without_contract=0 max_logic_lines=21 max_asserts per function=5 (visible_actions)
comments=0 (solo lo shebang)
tmux-menu.sh: 257 righe
tmux-menu.test.sh: 380 righe
```

## Test

- 51 passati, 0 falliti (server tmux isolato `-L tmtest` + client vero via `script`, fzf finto)
- giro 3: 52 passati, 0 falliti; il test dell'etichetta (`test_menu_lines_unknown_name_dies`) è stato visto rosso prima del fix
- mutanti: 15/15 uccisi (ogni predicato invertito, i bordi `> 1` / `>= 1`, l'etichetta tolta, query e scelta scambiate, la conferma che accetta tutto, la sessione non creata)
- non testati, come da spec: `act_save`, `act_restore`, `act_reload`, `act_command`
- `tmux.conf`: `source-file -n` ok (solo parsing; caricarla davvero su un server di test avrebbe fatto partire continuum e l'hook di salvataggio sul salvataggio reale). Giro 3: `set-titles` e `set-titles-string` provati su un server isolato separato (`-L tmcheck`, `-L tmvalid`), `show -g` e `display -p` danno `on` e `#S:#W`
- non provato: il popup aperto con `M-Esc` su un terminale vero

## Scostamenti

- **continuum**: fa l'autosave da `status-right`, quindi con la barra spenta smette senza avvisare (lo dice il suo README). Restore all'avvio invariato. Il salvataggio ora è un hook `client-detached` → `save.sh quiet`: scatta a ogni terminale chiuso, anche se ucciso (provato). Non c'è più il salvataggio ogni 15 minuti.
- **"ultima finestra"** = finestra precedente (`last-window`). Il run aveva scritto "l'ultima per indice". Corretto il corpo e l'input di `test_act_last_two_windows`, che creava la finestra con `-d` e così non aveva una finestra precedente.
- **corpi corretti a mano** (solo nelle righe todo, `check_body_diff.py` ok): regex di `is_name` (errore di sintassi), `act_new` senza `-c` della directory del pane, `act_command` eseguiva l'input senza quote invece di aprire `command-prompt`, `is_action` semplificato.
- **test**: tolti un self-oracle (`header` confrontato con la sua stessa formula), due duplicati e alcuni casi ridondanti; corretto il path del `source`.
- **file di test a 380 righe**: oltre il limite di 350. La regola vuole una cartella divisa per lavoro. In un repo di dotfiles mi sembra cerimonia: decidi tu.
- **tooling di ritchie**: nuovo foglio `references/languages/bash.md`; `th_write.sh` e `check_body_diff.py` ora riconoscono lo stub `die "todo: ..."`. `contract_report.py` non toccato.
- **senza linter né formatter**: `shellcheck` e `shfmt` non sono installati, ho fatto solo `bash -n`.
