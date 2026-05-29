from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import numpy as np
import pickle
import os
import json

app = FastAPI(title="Crop Recommendation API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

MODEL_DIR = os.path.join(os.path.dirname(__file__), "..", "models")

model = None
scaler = None
classes = []
lime_explainer = None

FEATURE_NAMES = ["Nitrogen", "phosphorus", "potassium", "temperature", "humidity", "ph", "rainfall"]


def load_model():
    global model, scaler, classes, lime_explainer

    model_path = os.path.join(MODEL_DIR, "optimized_stacking_ensemble.pkl")
    scaler_path = os.path.join(MODEL_DIR, "feature_scaler.pkl")
    encoder_path = os.path.join(MODEL_DIR, "crop_label_encoder.pkl")
    lime_path = os.path.join(MODEL_DIR, "lime_artifacts.pkl")

    for p in [model_path, scaler_path, encoder_path]:
        if not os.path.exists(p):
            raise RuntimeError(f"File not found: {p}")

    with open(model_path, "rb") as f:
        model = pickle.load(f)

    with open(scaler_path, "rb") as f:
        scaler = pickle.load(f)

    with open(encoder_path, "rb") as f:
        encoder = pickle.load(f)
    classes = encoder.classes_.tolist() if hasattr(encoder, "classes_") else encoder

    if os.path.exists(lime_path):
        with open(lime_path, "rb") as f:
            lime_explainer = pickle.load(f)


class PredictInput(BaseModel):
    Nitrogen: float
    phosphorus: float
    potassium: float
    temperature: float
    humidity: float
    ph: float
    rainfall: float


class PredictOutput(BaseModel):
    crop_en: str
    crop_ar: str
    confidence: float
    probabilities: dict[str, float]


class ExplainOutput(BaseModel):
    crop_en: str
    crop_ar: str
    confidence: float
    probabilities: dict[str, float]
    explanation: list[dict[str, float | str]]


CROP_ARABIC = {
    "rice": "أرز", "maize": "ذرة", "chickpea": "حمص", "kidneybeans": "فاصوليا",
    "pigeonpeas": "بازلاء", "mothbeans": "فول", "mungbean": "ماش",
    "blackgram": "جرام أسود", "lentil": "عدس", "pomegranate": "رمان",
    "banana": "موز", "mango": "مانجو", "grapes": "عنب", "watermelon": "بطيخ",
    "muskmelon": "شمام", "apple": "تفاح", "orange": "برتقال", "papaya": "باباي",
    "coconut": "جوز هند", "cotton": "قطن", "jute": "جوت", "coffee": "قهوة",
}


@app.on_event("startup")
async def startup():
    load_model()


@app.get("/crops")
async def list_crops():
    arabic_names = [CROP_ARABIC.get(c, c) for c in classes]
    return {"crops": classes, "crops_ar": arabic_names}


@app.post("/predict", response_model=PredictOutput)
async def predict(input: PredictInput):
    if model is None or scaler is None:
        raise HTTPException(status_code=503, detail="Model not loaded")

    raw = np.array([[
        input.Nitrogen, input.phosphorus, input.potassium,
        input.temperature, input.humidity, input.ph, input.rainfall
    ]], dtype=np.float32)

    scaled = scaler.transform(raw)
    probs = model.predict_proba(scaled)[0]
    best_idx = int(np.argmax(probs))
    best_crop = classes[best_idx]
    confidence = float(probs[best_idx])

    return PredictOutput(
        crop_en=best_crop,
        crop_ar=CROP_ARABIC.get(best_crop, best_crop),
        confidence=confidence,
        probabilities={classes[i]: float(p) for i, p in enumerate(probs)},
    )


@app.post("/explain", response_model=ExplainOutput)
async def explain(input: PredictInput):
    if model is None or scaler is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    if lime_explainer is None:
        raise HTTPException(status_code=503, detail="LIME explainer not loaded")

    raw = np.array([[
        input.Nitrogen, input.phosphorus, input.potassium,
        input.temperature, input.humidity, input.ph, input.rainfall
    ]], dtype=np.float32)

    scaled = scaler.transform(raw)
    probs = model.predict_proba(scaled)[0]
    best_idx = int(np.argmax(probs))
    best_crop = classes[best_idx]
    confidence = float(probs[best_idx])

    def predict_proba_fn(x):
        return model.predict_proba(scaler.transform(x))

    exp = lime_explainer.explain_instance(
        scaled[0],
        predict_proba_fn,
        num_features=len(FEATURE_NAMES),
        top_labels=1,
    )

    explanation = []
    for feature, weight in exp.as_list(label=best_crop):
        explanation.append({"feature": feature, "weight": round(weight, 4)})

    return ExplainOutput(
        crop_en=best_crop,
        crop_ar=CROP_ARABIC.get(best_crop, best_crop),
        confidence=confidence,
        probabilities={classes[i]: float(p) for i, p in enumerate(probs)},
        explanation=explanation,
    )


@app.get("/health")
async def health():
    return {"status": "ok", "model_loaded": model is not None}
