import hashlib
import os
from contextlib import asynccontextmanager

from fastapi import FastAPI
from pydantic import BaseModel, Field

from model_loader import load_model, model_loaded, model_path, predict_score, stub_score


class PredictRequest(BaseModel):
    resume_text: str = Field(min_length=1)
    vacancy_text: str = Field(min_length=1)


class PredictResponse(BaseModel):
    score: float


def use_stub() -> bool:
    return os.getenv("ML_STUB", "false").lower() == "true"


@asynccontextmanager
async def lifespan(app: FastAPI):
    if not use_stub():
        load_model()
    yield


app = FastAPI(title="HR Matcher ML Service", lifespan=lifespan)


@app.get("/health")
def health() -> dict:
    return {
        "status": "ok",
        "stub_mode": use_stub(),
        "model_path": model_path(),
        "model_loaded": model_loaded(),
    }


@app.post("/predict", response_model=PredictResponse)
def predict(payload: PredictRequest) -> PredictResponse:
    if use_stub():
        score = stub_score(payload.resume_text, payload.vacancy_text)
    else:
        score = predict_score(payload.resume_text, payload.vacancy_text)

    score = max(0.0, min(1.0, float(score)))
    return PredictResponse(score=score)
