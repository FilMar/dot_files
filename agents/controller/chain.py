import sqlite3
import asyncio
from pathlib import Path
from controller.models import ChainConfig, StepConfig
from controller.qdrant import get_qdrant, log_to_qdrant
from controller.runner import run_step


class Controller:
    def __init__(self, config: ChainConfig, project: str = "default", db_path: Path = Path("state.sqlite")):
        self.config = config
        self.project = project
        self.db_path = db_path
        self.qdrant = get_qdrant()
        self._init_db()

    def _init_db(self) -> None:
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("CREATE TABLE IF NOT EXISTS steps (name TEXT PRIMARY KEY, done INTEGER DEFAULT 0)")

    def is_step_done(self, name: str) -> bool:
        with sqlite3.connect(self.db_path) as conn:
            row = conn.execute("SELECT done FROM steps WHERE name = ?", (name,)).fetchone()
            return bool(row and row[0])

    def mark_step_done(self, name: str) -> None:
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("INSERT OR REPLACE INTO steps (name, done) VALUES (?, 1)", (name,))

    async def run(self) -> list[str]:
        results = []
        for step in self.config.steps:
            if self.is_step_done(step.name):
                continue
            last_exc: Exception | None = None
            for attempt in range(step.retry_max + 1):
                try:
                    output = await asyncio.wait_for(run_step(step), timeout=step.timeout)
                    log_to_qdrant(self.qdrant, self.project, self.config.chain_id, step.name, output)
                    self.mark_step_done(step.name)
                    results.append(output)
                    last_exc = None
                    break
                except Exception as e:
                    last_exc = e
            if last_exc is not None:
                raise last_exc
        return results
