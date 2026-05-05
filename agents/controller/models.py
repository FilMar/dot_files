import yaml
from pathlib import Path
from typing import Annotated, Literal
from pydantic import BaseModel, Field


class LLMStep(BaseModel):
    type: Literal["llm"]
    name: str
    prompt: str
    timeout: int = 90
    retry_max: int = 1


class ShellStep(BaseModel):
    type: Literal["shell"]
    name: str
    script: str
    timeout: int = 90
    retry_max: int = 1


class PipeStep(BaseModel):
    type: Literal["pipe"]
    name: str
    script: str
    prompt: str
    timeout: int = 90
    retry_max: int = 1


StepConfig = Annotated[LLMStep | ShellStep | PipeStep, Field(discriminator="type")]


class ChainConfig(BaseModel):
    chain_id: str
    steps: list[StepConfig]

    @classmethod
    def from_yaml(cls, path: Path) -> "ChainConfig":
        data = yaml.safe_load(path.read_text())
        return cls.model_validate(data)
