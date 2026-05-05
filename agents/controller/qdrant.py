import uuid
import httpx
from qdrant_client import QdrantClient
from qdrant_client.models import PointStruct, VectorParams, Distance

COLLECTION = "agent_logs"
QDRANT_URL = "http://localhost:6333"
OLLAMA_URL = "http://localhost:11434"
EMBED_MODEL = "nomic-embed-text"
EMBED_DIM = 768


def get_qdrant() -> QdrantClient:
    client = QdrantClient(url=QDRANT_URL)
    existing = [c.name for c in client.get_collections().collections]
    if COLLECTION not in existing:
        client.create_collection(
            COLLECTION,
            vectors_config=VectorParams(size=EMBED_DIM, distance=Distance.COSINE),
        )
    return client


def embed(text: str) -> list[float]:
    response = httpx.post(f"{OLLAMA_URL}/api/embeddings", json={"model": EMBED_MODEL, "prompt": text})
    response.raise_for_status()
    return response.json()["embedding"]


def log_to_qdrant(qdrant: QdrantClient, project: str, chain: str, step: str, output: str) -> None:
    payload = {"project": project, "chain": chain, "step": step, "what": output}
    qdrant.upsert(
        collection_name=COLLECTION,
        points=[PointStruct(id=str(uuid.uuid4()), vector=embed(output), payload=payload)],
    )
