# Sistema Agentico - Architettura

## Stack

- Orchestratore: Claude Sonnet (Segretario)
- Worker: Claude Haiku (risposte sempre JSON strutturato)
- Controller: Python + asyncio
- Stato operativo: SQLite
- Memoria narrativa: Qdrant
- Supervisione processi: supervisord
- Versioning chain: Git
- Budget: ~50 euro/mese via API Anthropic

---

## Componenti

### Segretario

- Claude Sonnet, orchestratore ad alto livello
- assegna obiettivi ai Controller di chain
- riprende il contesto da SQLite a ogni sessione
- a fine sessione legge da Qdrant e genera due file Markdown per l'umano
- unico punto di coordinamento tra chain diverse

### Controller di Chain

- Python + asyncio: legge YAML, esegue script, chiama Haiku, scrive su SQLite
- supervisord gestisce crash, restart e timeout a livello di processo
- lo stato non e' nel processo: e' tutto su SQLite
- se il processo muore e rinasce, legge da SQLite dove era arrivato
- mypy strict + Pydantic per validazione YAML al boot
- setta flag su SQLite dopo ogni step completato
- setta `worker_done` solo dopo conferma scrittura su Qdrant

### Worker Agent

- stateless: si sveglia, riceve ruolo e ordini, lavora, registra, muore
- implementato con script shell/CLI dove possibile
- Claude solo se serve ragionamento o generazione
- ultimo step obbligatorio: scrittura su Qdrant
- formato log narrativo Qdrant:

```json
{
  "project": "nome_progetto",
  "chain": "thinking_v1",
  "step": "nome_step",
  "what": "cosa ha fatto",
  "why": "perche' lo ha fatto",
  "output_ref": ".agent/thinking/output.md"
}
```

### Chain di Metathinking

- osserva log e performance delle chain attive
- propone nuove chain o modifiche come YAML
- output: documento Markdown + YAML leggibile
- gate umano obbligatorio prima di ogni esecuzione

---

## Chain

Ogni chain e' un file YAML versionato su Git. Schema base:

```yaml
chain_id: research_v1
steps:
  - script: ./agents/search.sh
    haiku_prompt_template: "riassumi questo output: {output}"
    timeout: 60
    retry_max: 3
  - script: ./agents/summarize.sh
    timeout: 120
    retry_max: 2
defaults:
  timeout: 90
  retry_max: 3
```

- schema validato con Pydantic al boot
- ogni step ha un campo opzionale `haiku_prompt_template`
- zero logica specifica nel Controller: tutta la variabilita' sta nello YAML
- mai sovrascrivere: nuove versioni come file separati (v1, v2...)
- rollback gratuito tramite Git
- il metathinking propone YAML modificati, l'umano approva prima del deploy

### Chain Fondamentali

- `thinking.yaml`: ricerca, analisi, raffinazione documenti
- `programming.yaml`: codice, test, review
- `meta.yaml`: osserva le altre due, propone modifiche

---

## Struttura File di Progetto

```
./nome_progetto/
  README.md              # output finale leggibile dall'umano
  .agent/
    thinking/            # MD intermedi prodotti dalla chain thinking
    tasks/               # task breakdown prodotti dalla chain programming
    state.sqlite         # stato operativo locale della sessione
```

---

## Configurazione

Convenzione unix: config globale, override locale.

- `~/.config/agent/`: config globale, chain di base, credenziali
- `./<progetto>/`: YAML di progetto, chain custom, stato SQLite locale
- precedenza: locale batte globale
- avviare il sistema da una cartella di progetto carica automaticamente la config locale

---

## Flusso di una Sessione

```
Umano
  |
  v
Segretario (Sonnet)
  |-- avvia thinking.yaml
  |     |-- step 1: domande, ricerca
  |     |-- step 2: raffinazione
  |     |-- step N: documenti MD in .agent/thinking/
  |
  |-- [gate umano: approva documenti]
  |
  |-- avvia programming.yaml
  |     |-- step 1: divide in task
  |     |-- step 2..N: sviluppo
  |
  v
fine sessione:
  Segretario legge Qdrant
  genera summary.md e ideas.md
```

---

## Output per l'Umano

- `summary.md`: riassunto del lavoro svolto nella sessione
- `ideas.md`: concetti interessanti, spunti, osservazioni emerse

---

## Principi

- deterministico ovunque sia possibile
- LLM solo dove serve ragionamento o generazione
- worker seriali: nessun problema di concorrenza su SQLite
- ogni modifica del metathinking e' approvata dall'umano
- SQLite per stato operativo, Qdrant per memoria narrativa e retrieval semantico
- tutto e' una chain, incluse thinking, programming e meta
- Git e' il version control dei YAML, nessun meccanismo aggiuntivo necessario
- Qdrant si popola da subito: i log narrativi accumulati sono il valore del sistema nel tempo

---

## Domande Aperte

1. **Contratto Segretario -> Controller**: come passa l'obiettivo? File JSON in `.agent/`, chiamata MCP diretta, o altro? Questo e' il punto di rottura piu' probabile dell'intero sistema.

2. **Qdrant down**: se Qdrant non risponde, il worker ha gia' lavorato ma non puo' completare l'ultimo step. Il Controller blocca la chain o setta `worker_done` comunque accettando la perdita del log?

3. **Context window del Segretario**: con sessioni lunghe, leggere tutta Qdrant per generare i due MD rischia di superare la context window. Serve una strategia di retrieval selettivo.

4. **Validazione logica dei YAML**: Pydantic valida lo schema, non la logica. Un YAML sintatticamente corretto ma semanticamente sbagliato passa il boot. Serve un dry-run in sandbox prima del deploy?

5. **Gate umano - meccanismo concreto**: "l'umano approva" e' un principio, non ancora un'implementazione. File sentinel `.agent/approved.flag`? Input da terminale? Va definito prima di scrivere il Controller.
