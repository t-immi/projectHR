"""
Загрузка дообученной SentenceTransformer-модели resume_model_v2_epoch_3.

Модель обучена на парах (резюме, вакансия) с CosineSimilarityLoss.
Оценка совпадения — косинусное сходство эмбеддингов (диапазон 0–1).
"""

import hashlib
import os
from functools import lru_cache
from pathlib import Path

DEFAULT_MODEL_PATH = Path(__file__).resolve().parent / "resume_model_v2_epoch_3"


def model_path() -> str:
    return os.getenv("MODEL_PATH", str(DEFAULT_MODEL_PATH))


def stub_score(resume_text: str, vacancy_text: str) -> float:
    digest = hashlib.sha256(f"{resume_text}::{vacancy_text}".encode("utf-8")).hexdigest()
    return (int(digest, 16) % 10_000) / 10_000.0


@lru_cache(maxsize=1)
def load_model():
    path = Path(model_path())
    if not path.exists():
        return None

    from sentence_transformers import SentenceTransformer

    return SentenceTransformer(str(path))


def model_loaded() -> bool:
    return load_model() is not None


def predict_score(resume_text: str, vacancy_text: str) -> float:
    model = load_model()
    if model is None:
        return stub_score(resume_text, vacancy_text)

    from sentence_transformers.util import cos_sim

    resume_embedding, vacancy_embedding = model.encode(
        [resume_text, vacancy_text],
        normalize_embeddings=True,
        show_progress_bar=False,
    )
    score = float(cos_sim(resume_embedding, vacancy_embedding).item())
    return max(0.0, min(1.0, score))
