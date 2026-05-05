import asyncio
import anthropic
from controller.models import LLMStep, ShellStep, PipeStep, StepConfig


async def _call_llm(prompt: str) -> str:
    client = anthropic.AsyncAnthropic()
    response = await client.messages.create(
        model="claude-haiku-4-5-20251001",
        max_tokens=1024,
        messages=[{"role": "user", "content": prompt}],
    )
    return response.content[0].text


async def _run_script(script: str) -> str:
    proc = await asyncio.create_subprocess_shell(
        script,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.STDOUT,
    )
    stdout, _ = await proc.communicate()
    return stdout.decode()


async def run_step(step: StepConfig) -> str:
    match step:
        case LLMStep():
            return await _call_llm(step.prompt)
        case ShellStep():
            return await _run_script(step.script)
        case PipeStep():
            output = await _run_script(step.script)
            return await _call_llm(step.prompt.format(output=output))
