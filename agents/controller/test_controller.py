import pytest
import tempfile
from pathlib import Path
from unittest.mock import AsyncMock, MagicMock, patch
from controller.models import ChainConfig, LLMStep, ShellStep, PipeStep
from controller.chain import Controller
from controller.qdrant import embed, log_to_qdrant
from controller.runner import run_step


VALID_YAML = """
chain_id: test_v1
steps:
  - type: llm
    name: step_one
    prompt: "di' solo: done"
    timeout: 30
    retry_max: 2
  - type: llm
    name: step_two
    prompt: "di' solo: done"
    timeout: 30
    retry_max: 2
"""

NO_RETRY_YAML = """
chain_id: test_v1
steps:
  - type: llm
    name: step_one
    prompt: "di' solo: done"
    timeout: 30
    retry_max: 0
  - type: llm
    name: step_two
    prompt: "di' solo: done"
    timeout: 30
    retry_max: 0
"""

INVALID_YAML = """
steps:
  - prompt: "manca chain_id e name"
"""

INVALID_TYPE_YAML = """
chain_id: test_v1
steps:
  - type: unknown
    name: step_one
"""


def write_yaml(content: str) -> Path:
    f = tempfile.NamedTemporaryFile(suffix=".yaml", delete=False, mode="w")
    f.write(content)
    f.close()
    return Path(f.name)


def make_controller(yaml_content: str, db_path: Path) -> Controller:
    with patch("controller.qdrant.get_qdrant", return_value=MagicMock()):
        config = ChainConfig.from_yaml(write_yaml(yaml_content))
        return Controller(config, project="test", db_path=db_path)


def test_valid_yaml_parses():
    path = write_yaml(VALID_YAML)
    config = ChainConfig.from_yaml(path)
    assert config.chain_id == "test_v1"
    assert len(config.steps) == 2


def test_invalid_yaml_raises_at_boot():
    path = write_yaml(INVALID_YAML)
    with pytest.raises(Exception):
        ChainConfig.from_yaml(path)


def test_invalid_step_type_raises_at_boot():
    path = write_yaml(INVALID_TYPE_YAML)
    with pytest.raises(Exception):
        ChainConfig.from_yaml(path)


@pytest.mark.asyncio
async def test_step_failure_stops_chain():
    with tempfile.TemporaryDirectory() as tmp:
        controller = make_controller(NO_RETRY_YAML, Path(tmp) / "state.sqlite")
        with patch("controller.chain.run_step", new_callable=AsyncMock) as mock_run, \
             patch("controller.chain.log_to_qdrant"):
            mock_run.side_effect = [RuntimeError("step fallito"), None]
            with pytest.raises(RuntimeError):
                await controller.run()
            assert mock_run.call_count == 1


def test_embed_returns_768_dimensions():
    fake_vector = [0.1] * 768
    with patch("controller.qdrant.httpx") as mock_httpx:
        mock_response = MagicMock()
        mock_response.json.return_value = {"embedding": fake_vector}
        mock_httpx.post.return_value = mock_response
        result = embed("testo di prova")
    assert len(result) == 768


def test_log_to_qdrant_payload():
    mock_qdrant = MagicMock()
    with patch("controller.qdrant.embed", return_value=[0.0] * 768):
        log_to_qdrant(mock_qdrant, "progetto", "chain_v1", "step_uno", "output testo")
    point = mock_qdrant.upsert.call_args.kwargs["points"][0]
    assert point.payload["project"] == "progetto"
    assert point.payload["chain"] == "chain_v1"
    assert point.payload["step"] == "step_uno"
    assert point.payload["what"] == "output testo"


@pytest.mark.asyncio
async def test_controller_logs_once_per_step():
    with tempfile.TemporaryDirectory() as tmp:
        controller = make_controller(VALID_YAML, Path(tmp) / "state.sqlite")
        with patch("controller.chain.run_step", new_callable=AsyncMock, return_value="output"), \
             patch("controller.chain.log_to_qdrant") as mock_log:
            await controller.run()
            assert mock_log.call_count == 2


@pytest.mark.asyncio
async def test_completed_step_flagged_in_sqlite():
    with tempfile.TemporaryDirectory() as tmp:
        db = Path(tmp) / "state.sqlite"
        controller = make_controller(VALID_YAML, db)
        with patch("controller.chain.run_step", new_callable=AsyncMock, return_value="output"), \
             patch("controller.chain.log_to_qdrant"):
            await controller.run()
        assert controller.is_step_done("step_one")
        assert controller.is_step_done("step_two")


@pytest.mark.asyncio
async def test_resume_skips_completed_steps():
    with tempfile.TemporaryDirectory() as tmp:
        db = Path(tmp) / "state.sqlite"
        controller = make_controller(VALID_YAML, db)
        controller.mark_step_done("step_one")
        with patch("controller.chain.run_step", new_callable=AsyncMock, return_value="output") as mock_run, \
             patch("controller.chain.log_to_qdrant"):
            await controller.run()
            assert mock_run.call_count == 1, "step_one gia' completato non deve essere rieseguito"


@pytest.mark.asyncio
async def test_retry_on_failure():
    with tempfile.TemporaryDirectory() as tmp:
        controller = make_controller(VALID_YAML, Path(tmp) / "state.sqlite")
        with patch("controller.chain.run_step", new_callable=AsyncMock) as mock_run, \
             patch("controller.chain.log_to_qdrant"):
            mock_run.side_effect = [RuntimeError("fail"), RuntimeError("fail"), "ok", "ok"]
            await controller.run()
            assert mock_run.call_count == 4, "due retry per step_one, poi step_two al primo tentativo"


@pytest.mark.asyncio
async def test_run_step_llm_is_truly_async():
    step = LLMStep(type="llm", name="s", prompt="x", timeout=5)
    with patch("controller.runner.anthropic.AsyncAnthropic") as mock_cls:
        mock_client = MagicMock()
        mock_client.messages.create = AsyncMock(return_value=MagicMock(content=[MagicMock(text="ok")]))
        mock_cls.return_value = mock_client
        result = await run_step(step)
    assert result == "ok"
    mock_client.messages.create.assert_awaited_once()


@pytest.mark.asyncio
async def test_shell_step_executes_script():
    step = ShellStep(type="shell", name="s", script="echo hello", timeout=5)
    result = await run_step(step)
    assert result.strip() == "hello"


@pytest.mark.asyncio
async def test_pipe_step_interpolates_output():
    step = PipeStep(type="pipe", name="s", script="echo world", prompt="input era: {output}", timeout=5)
    with patch("controller.runner.anthropic.AsyncAnthropic") as mock_cls:
        mock_client = MagicMock()
        mock_client.messages.create = AsyncMock(return_value=MagicMock(content=[MagicMock(text="ok")]))
        mock_cls.return_value = mock_client
        await run_step(step)
    call_args = mock_client.messages.create.call_args
    assert "world" in call_args.kwargs["messages"][0]["content"]


@pytest.mark.asyncio
async def test_retry_exhausted_raises():
    with tempfile.TemporaryDirectory() as tmp:
        controller = make_controller(VALID_YAML, Path(tmp) / "state.sqlite")
        with patch("controller.chain.run_step", new_callable=AsyncMock) as mock_run, \
             patch("controller.chain.log_to_qdrant"):
            mock_run.side_effect = RuntimeError("fail sempre")
            with pytest.raises(RuntimeError):
                await controller.run()
            assert mock_run.call_count == 3, "retry_max=2 significa 1 tentativo iniziale + 2 retry"
