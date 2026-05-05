import asyncio
import sys
from pathlib import Path
from controller.chain import ChainConfig, Controller


async def main(yaml_path: str) -> None:
    config = ChainConfig.from_yaml(Path(yaml_path))
    print(f"chain: {config.chain_id} ({len(config.steps)} steps)")
    controller = Controller(config)
    results = await controller.run()
    for step, output in zip(config.steps, results):
        print(f"\n--- {step.name} ---\n{output}")


if __name__ == "__main__":
    asyncio.run(main(sys.argv[1]))
