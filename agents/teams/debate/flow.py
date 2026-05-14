"""
debate — flow di dibattito strutturato per raccogliere requisiti e produrre un documento.

Ruoli richiesti (in roles/):
  analista    — analizza i documenti sorgente nel contesto iniziale
  domandatore — formula la prossima domanda da porre all'utente
  elaboratore — sintetizza le risposte in un documento strutturato
  ricercatore — cerca riferimenti e best practice sul web
  scrittore   — produce il file finale via filesystem MCP

Tool MCP:
  filesystem — read per tutti; write per scrittore
  web_search — usato dal ricercatore
"""

from pathlib import Path
from alfred.flow.dsl import LLMNode, JudgeNode, build_flow
from alfred.flow.shortcuts import interrupt_node, split_tools
from alfred.flow.mcp_servers import FILESYSTEM, WEB_SEARCH
from alfred.config.paths import TeamPaths

MCP_SERVERS = {
    "filesystem": FILESYSTEM,
    "web_search": WEB_SEARCH,
}

DEFAULT_CRITERIA = (
    "le informazioni raccolte sono sufficienti per produrre un documento completo e specifico, "
    "senza ambiguita' rilevanti sul contenuto, la struttura e il destinatario del documento; "
    "oppure l'utente ha esplicitamente segnalato di voler procedere"
)


def build(team_dir: Path, checkpointer, config, tools: list = None) -> object:
    t = split_tools(tools or [])
    role = TeamPaths(team_dir).role

    return build_flow([
        LLMNode(name="analista",    role=role("analista"),    tools=t["read"],   to="domandatore"),
        LLMNode(name="domandatore", role=role("domandatore"), tools=t["read"],   to="interrupt"),
        interrupt_node(to="elaboratore"),
        LLMNode(name="elaboratore", role=role("elaboratore"), tools=t["read"],   to="giudice"),
        JudgeNode(name="giudice", criteria=DEFAULT_CRITERIA,
                  route=lambda s: "ricercatore" if s["passed"] else "domandatore"),
        LLMNode(name="ricercatore", role=role("ricercatore"), tools=t["search"], to="scrittore"),
        LLMNode(name="scrittore",   role=role("scrittore"),   tools=t["write"]),
    ], config=config, checkpointer=checkpointer)
