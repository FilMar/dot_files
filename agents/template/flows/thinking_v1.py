"""
thinking_v1 — flow per studio e analisi di un tema.

Slot richiesti:
  web_research   — ricercatore con accesso a web_search MCP
  faction_a      — agente che sposa la fazione principale A
  faction_b      — agente che sposa la fazione principale B
  faction_others — agente che rappresenta le posizioni rimanenti
  perspective    — agente esterno che verifica bias e cambia prospettiva
  synthesizer    — produce il file .md finale via MCP filesystem
                   (legge output_path dal primo messaggio del transcript)

Slot opzionali:
  criteria     — criteri del judge (default: vedi sotto)

Tool MCP:
  web_search  — solo web_research
  filesystem  — tutti leggono; synthesizer scrive anche
"""

from pathlib import Path
from alfred.flow.dsl import LLMNode, JudgeNode, build_flow
from alfred.flow.shortcuts import escalate_node, retry_route, split_tools
from alfred.flow.mcp_servers import FILESYSTEM, WEB_SEARCH
from alfred.config.paths import TeamPaths


SLOTS = {
    "web_research":   "ricerca informazioni sul tema — usa SOLO web_search, non scrive file, produce un riassunto delle fonti trovate",
    "faction_a":      "argomenta la posizione principale A — produce SOLO un documento argomentativo, non scrive file",
    "faction_b":      "argomenta la posizione principale B — produce SOLO un documento argomentativo, non scrive file",
    "faction_others": "rappresenta le posizioni minoritarie — produce SOLO un documento argomentativo, non scrive file",
    "confronto":      "mappa le divergenze tra le fazioni — produce SOLO un documento di analisi comparativa, non scrive file",
    "perspective":    "verifica bias e cambia prospettiva — produce SOLO un documento critico, non scrive file",
    "synthesizer":    "produce la sintesi finale — scrive SOLO il file .md di output, non modifica altri file",
}

MCP_SERVERS = {
    "filesystem": FILESYSTEM,
    "web_search": WEB_SEARCH,
}

DEFAULT_CRITERIA = (
    "le tre fazioni sono rappresentate con argomenti solidi, "
    "la prospettiva esterna ha identificato almeno un bias, "
    "la sintesi e' coerente e non appiattisce le differenze"
)


def build(team_dir: Path, checkpointer, config, tools: list = None) -> object:
    t = split_tools(tools or [])
    role = TeamPaths(team_dir).role

    return build_flow([
        LLMNode(name="web_research",   role=role("web_research"),   tools=t["search"], to="faction_a"),
        LLMNode(name="faction_a",      role=role("faction_a"),      tools=t["read"],   to="faction_b"),
        LLMNode(name="faction_b",      role=role("faction_b"),      tools=t["read"],   to="faction_others"),
        LLMNode(name="faction_others", role=role("faction_others"), tools=t["read"],   to="perspective"),
        LLMNode(name="perspective",    role=role("perspective"),    tools=t["read"],   to="judge"),
        JudgeNode(name="judge", criteria=DEFAULT_CRITERIA,
                  route=retry_route(on_pass="synthesizer", on_retry="faction_a")),
        LLMNode(name="synthesizer", role=role("synthesizer"), tools=t["write"]),
        escalate_node(),
    ], config=config, checkpointer=checkpointer)
