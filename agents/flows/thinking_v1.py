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
from langgraph.graph import StateGraph, END
from langgraph.types import interrupt
from alfred.flow.engine import llm_node, judge_node, BaseFlowState
from alfred.flow.mcp_servers import FILESYSTEM, WEB_SEARCH


SLOTS = ["web_research", "faction_a", "faction_b", "faction_others", "perspective", "synthesizer"]

MCP_SERVERS = {
    "filesystem": FILESYSTEM,
    "web_search": WEB_SEARCH,
}

DEFAULT_CRITERIA = (
    "le tre fazioni sono rappresentate con argomenti solidi, "
    "la prospettiva esterna ha identificato almeno un bias, "
    "la sintesi e' coerente e non appiattisce le differenze"
)

_WRITE_NAMES = {"write", "create", "move", "delete"}


def build(llm, team_dir: Path, checkpointer, tools: list = None) -> object:
    tools = tools or []
    criteria = DEFAULT_CRITERIA

    search_tools = [t for t in tools if "search" in t.name.lower()]
    read_tools   = [t for t in tools if "search" not in t.name.lower()
                    and not any(w in t.name for w in _WRITE_NAMES)]
    write_tools  = [t for t in tools if "search" not in t.name.lower()]

    def role(name: str) -> Path:
        return team_dir / "roles" / f"{name}.md"

    web_research_node   = llm_node(llm, role("web_research"),   why="cercare informazioni sul tema",                        tools=search_tools)
    faction_a_node      = llm_node(llm, role("faction_a"),      why="argomentare dalla prospettiva della fazione A",        tools=read_tools)
    faction_b_node      = llm_node(llm, role("faction_b"),      why="argomentare dalla prospettiva della fazione B",        tools=read_tools)
    faction_others_node = llm_node(llm, role("faction_others"), why="rappresentare le posizioni minoritarie o alternative", tools=read_tools)
    perspective_node    = llm_node(llm, role("perspective"),    why="identificare bias e cambiare prospettiva",             tools=read_tools)
    synthesizer_node    = llm_node(llm, role("synthesizer"),    why="produrre la sintesi finale",                          tools=write_tools)
    judge               = judge_node(llm, criteria=criteria)

    def escalate_node(state: BaseFlowState) -> dict:
        context = "\n".join(f"{m['who']}: {m['what']}" for m in state["messages"])
        interrupt(f"max tentativi raggiunti.\n\n{context}")
        return {}

    def route(state: BaseFlowState) -> str:
        if state["passed"]:
            return "synthesizer"
        if state["attempts"] >= state["max_attempts"]:
            return "escalate"
        return "faction_a"

    graph = StateGraph(BaseFlowState)
    graph.add_node("web_research",     web_research_node)
    graph.add_node("faction_a",        faction_a_node)
    graph.add_node("faction_b",        faction_b_node)
    graph.add_node("faction_others",   faction_others_node)
    graph.add_node("perspective",      perspective_node)
    graph.add_node("judge",            judge)
    graph.add_node("synthesizer",      synthesizer_node)
    graph.add_node("escalate",         escalate_node)

    graph.set_entry_point("web_research")
    graph.add_edge("web_research",   "faction_a")
    graph.add_edge("faction_a",      "faction_b")
    graph.add_edge("faction_b",      "faction_others")
    graph.add_edge("faction_others", "perspective")
    graph.add_edge("perspective",    "judge")
    graph.add_conditional_edges("judge", route, {
        "synthesizer": "synthesizer",
        "faction_a":   "faction_a",
        "escalate":    "escalate",
    })
    graph.add_edge("synthesizer", END)

    return graph.compile(checkpointer=checkpointer)
