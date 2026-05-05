# Sistema Agentico - Architettura

## Stack

- Orchestratore: Claude Sonnet (Segretario)
- Worker: Claude Haiku (risposte sempre JSON strutturato)
- Controller: Python + asyncio
- Stato operativo: SQLite (locale per progetto)
- Memoria narrativa e output: Qdrant (globale, unica collection)
- Supervisione processi: supervisord
- Versioning chain: Git
- Budget: ~50 euro/mese via API Anthropic

---

## Componenti

### Segretario

- Claude Sonnet, orchestratore ad alto livello
- avvia il Controller via MCP passando `chain_yaml` e `project_dir`
- riprende il contesto da Qdrant a ogni sessione (retrieval per `project`)
- genera MD solo se l'umano li richiede esplicitamente
- unico punto di coordinamento tra chain diverse

### Controller di Chain

- Python + asyncio: legge YAML, esegue script, chiama Haiku, scrive su SQLite
- avviato dal Segretario via MCP con `chain_yaml` e `project_dir`
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
  "output": "testo o JSON inline dell'output"
}
```

### Chain di Metathinking

- osserva log e performance delle chain attive
- propone nuove chain o modifiche come YAML
- gate umano obbligatorio prima di ogni esecuzione

---

## Qdrant

- collection unica globale: tutti i progetti nello stesso spazio vettoriale
- filtro per `project` nel payload per retrieval contestuale
- vantaggio: retrieval semantico cross-progetto (esempi, pattern, soluzioni passate)
- nessun file MD volante: tutto persiste qui
- dashboard web su porta 6333 per ispezione diretta

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

- `thinking.yaml`: ricerca, analisi, raffinazione
- `programming.yaml`: codice, test, review
- `meta.yaml`: osserva le altre due, propone modifiche

---

## Struttura File di Progetto

```
./nome_progetto/
  README.md          # unico MD fisso, scritto dal Segretario a fine sessione
  .agent/
    state.sqlite     # stato operativo locale (flag, retry, lock)
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
  |-- avvia Controller via MCP (chain_yaml, project_dir)
  |     |-- thinking.yaml
  |     |     |-- step 1..N: output scritti su Qdrant
  |     |
  |     |-- [gate umano]
  |     |
  |     |-- programming.yaml
  |           |-- step 1..N: output scritti su Qdrant
  |
  v
fine sessione:
  Segretario legge Qdrant (retrieval selettivo per project + session)
  scrive README.md
  genera MD aggiuntivi solo se richiesti dall'umano
```

---

## Principi

- deterministico ovunque sia possibile
- LLM solo dove serve ragionamento o generazione
- worker seriali: nessun problema di concorrenza su SQLite
- ogni modifica del metathinking e' approvata dall'umano
- SQLite per stato operativo, Qdrant per tutto il persistente
- tutto e' una chain, incluse thinking, programming e meta
- Git e' il version control dei YAML, nessun meccanismo aggiuntivo necessario
- Qdrant si popola da subito: i log accumulati cross-progetto sono il valore del sistema

---

## Domande Aperte

1. **Qdrant down**: se Qdrant non risponde, il worker ha gia' lavorato ma non puo' completare l'ultimo step. Il Controller blocca la chain o accetta la perdita del log?

2. **Validazione logica dei YAML**: Pydantic valida lo schema, non la logica. Serve un dry-run in sandbox prima del deploy?

3. **Gate umano - meccanismo concreto**: file sentinel `.agent/gate.flag` con polling del Controller, o input interattivo?
