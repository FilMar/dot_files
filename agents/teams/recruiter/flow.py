"""
recruiter — flow per generare i ruoli di un nuovo team.

Invocato da `alfred team build`. Può essere eseguito anche via `alfred run --team recruiter --global`.
"""

from pathlib import Path
import os


def build(team_dir: Path, checkpointer, config, **kwargs):
    base = os.environ.get("ALFRED_CONFIG_DIR", Path.home() / ".config" / "alfred")
    from alfred.config.paths import GlobalPaths
    from alfred.team.recruiter import build as _build
    return _build(GlobalPaths(Path(base)), team_dir, config, checkpointer=checkpointer)
