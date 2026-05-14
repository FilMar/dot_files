"""
programming_v1 — flow per implementazione di un task da backlog.

Slot richiesti:
  proposer_a   — agente con approccio pragmatico/ottimista
  proposer_b   — agente con approccio critico/cauto
  architect    — genera skeleton (classi, firme vuote, costanti)
  test_writer  — scrive i test sulle firme dell'architect
  algorithmer  — implementa le funzioni fino a far passare i test
  cleaner      — verifica DRY e SOLID, propone miglioramenti
  reviewer     — produce reviews/<task_id>.md via MCP filesystem
                 (legge task-id dal primo messaggio del transcript)

Slot opzionali:
  criteria       — criteri del judge (default: vedi sotto)
  test_command   — comando per i test (default: pytest --tb=short)

Tool MCP:
  filesystem — tutti gli agenti leggono; architect, test_writer,
               algorithmer, reviewer scrivono anche
"""

from pathlib import Path
from alfred.flow.dsl import LLMNode, JudgeNode, ShellNode, build_flow
from alfred.flow.shortcuts import escalate_node, retry_route, split_tools
from alfred.flow.mcp_servers import FILESYSTEM
from alfred.config.paths import TeamPaths


SLOTS = {
    "proposer_a":  "propone un approccio — produce SOLO un documento di proposta testuale, non scrive né modifica file",
    "proposer_b":  "propone un approccio alternativo — produce SOLO un documento di proposta testuale, non scrive né modifica file",
    "confronto":   "confronta le due proposte — produce SOLO un documento di sintesi e raccomandazione, non scrive né modifica file",
    "architect":   "genera lo skeleton — scrive SOLO firme vuote, classi e costanti senza implementazione",
    "test_writer": "scrive i test — crea SOLO file di test sulle firme dell'architect, non tocca il codice sorgente",
    "algorithmer": "implementa — scrive SOLO il corpo delle funzioni già definite per far passare i test",
    "cleaner":     "revisiona — legge il codice e suggerisce miglioramenti DRY/SOLID, non riscrive autonomamente",
    "reviewer":    "documenta — scrive SOLO il file di review in reviews/, non modifica codice",
}

MCP_SERVERS = {
    "filesystem": FILESYSTEM,
}

DEFAULT_CRITERIA = (
    "tutti i test passano, il cleaner non ha segnalato violazioni DRY o SOLID critiche, "
    "il codice e' leggibile e la review e' presente in reviews/"
)


def build(team_dir: Path, checkpointer, config, tools: list = None) -> object:
    t = split_tools(tools or [])
    test_command = "pytest --tb=short"
    role = TeamPaths(team_dir).role

    return build_flow([
        LLMNode(name="proposer_a",  role=role("proposer_a"),  tools=t["read"],  to="proposer_b"),
        LLMNode(name="proposer_b",  role=role("proposer_b"),  tools=t["read"],  to="architect"),
        LLMNode(name="architect",   role=role("architect"),   tools=t["write"], to="test_writer"),
        LLMNode(name="test_writer", role=role("test_writer"), tools=t["write"], to="algorithmer"),
        LLMNode(name="algorithmer", role=role("algorithmer"), tools=t["write"], to="pytest"),
        ShellNode(name="pytest",      command=test_command,                      to="cleaner"),
        LLMNode(name="cleaner",     role=role("cleaner"),     tools=t["read"],  to="pytest_post"),
        ShellNode(name="pytest_post", command=test_command,                      to="judge"),
        JudgeNode(name="judge", criteria=DEFAULT_CRITERIA,
                  route=retry_route(on_pass="reviewer", on_retry="algorithmer")),
        LLMNode(name="reviewer", role=role("reviewer"), tools=t["write"]),
        escalate_node(),
    ], config=config, checkpointer=checkpointer)
