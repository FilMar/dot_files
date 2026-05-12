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
from langgraph.graph import StateGraph, END
from langgraph.types import interrupt
from alfred.flow.engine import llm_node, shell_node, judge_node, BaseFlowState
from alfred.flow.mcp_servers import FILESYSTEM


SLOTS = ["proposer_a", "proposer_b", "architect", "test_writer", "algorithmer", "cleaner", "reviewer"]

MCP_SERVERS = {
    "filesystem": FILESYSTEM,
}

DEFAULT_CRITERIA = (
    "tutti i test passano, il cleaner non ha segnalato violazioni DRY o SOLID critiche, "
    "il codice e' leggibile e la review e' presente in reviews/"
)

_WRITE_NAMES = {"write", "create", "move", "delete"}


def build(llm, team_dir: Path, checkpointer, tools: list = None) -> object:
    tools = tools or []
    criteria     = DEFAULT_CRITERIA
    test_command = "pytest --tb=short"

    read_tools  = [t for t in tools if not any(w in t.name for w in _WRITE_NAMES)]
    write_tools = tools

    def role(name: str) -> Path:
        return team_dir / "roles" / f"{name}.md"

    proposer_a_node  = llm_node(llm, role("proposer_a"),  why="proporre un approccio pragmatico al task",               tools=read_tools)
    proposer_b_node  = llm_node(llm, role("proposer_b"),  why="proporre un approccio critico al task",                  tools=read_tools)
    architect_node   = llm_node(llm, role("architect"),   why="generare lo skeleton: classi, firme vuote, costanti",    tools=write_tools)
    test_writer_node = llm_node(llm, role("test_writer"), why="scrivere i test sulle firme dell'architect",             tools=write_tools)
    algorithmer_node = llm_node(llm, role("algorithmer"), why="implementare le funzioni per far passare i test",        tools=write_tools)
    pytest_node      = shell_node(test_command)
    cleaner_node     = llm_node(llm, role("cleaner"),     why="verificare DRY e SOLID e proporre miglioramenti",        tools=read_tools)
    pytest_post_node = shell_node(test_command)
    reviewer_node    = llm_node(llm, role("reviewer"),    why="documentare il task completato",                         tools=write_tools)
    judge            = judge_node(llm, criteria=criteria)

    def escalate_node(state: BaseFlowState) -> dict:
        context = "\n".join(f"{m['who']}: {m['what']}" for m in state["messages"])
        interrupt(f"max tentativi raggiunti\n\n{context}")
        return {}

    def route(state: BaseFlowState) -> str:
        if state["passed"]:
            return "reviewer"
        if state["attempts"] >= state["max_attempts"]:
            return "escalate"
        return "algorithmer"

    graph = StateGraph(BaseFlowState)
    graph.add_node("proposer_a",   proposer_a_node)
    graph.add_node("proposer_b",   proposer_b_node)
    graph.add_node("architect",    architect_node)
    graph.add_node("test_writer",  test_writer_node)
    graph.add_node("algorithmer",  algorithmer_node)
    graph.add_node("pytest",       pytest_node)
    graph.add_node("cleaner",      cleaner_node)
    graph.add_node("pytest_post",  pytest_post_node)
    graph.add_node("judge",        judge)
    graph.add_node("reviewer",     reviewer_node)
    graph.add_node("escalate",     escalate_node)

    graph.set_entry_point("proposer_a")
    graph.add_edge("proposer_a",  "proposer_b")
    graph.add_edge("proposer_b",  "architect")
    graph.add_edge("architect",   "test_writer")
    graph.add_edge("test_writer", "algorithmer")
    graph.add_edge("algorithmer", "pytest")
    graph.add_edge("pytest",      "cleaner")
    graph.add_edge("cleaner",     "pytest_post")
    graph.add_edge("pytest_post", "judge")
    graph.add_conditional_edges("judge", route, {
        "reviewer":    "reviewer",
        "algorithmer": "algorithmer",
        "escalate":    "escalate",
    })
    graph.add_edge("reviewer", END)

    return graph.compile(checkpointer=checkpointer)
