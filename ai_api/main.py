from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import numpy as np
import tensorflow as tf
import os

app = FastAPI()

# Load your trained model (update the path as needed)
MODEL_PATH = os.getenv('LSTM_MODEL_PATH', 'AI_model/backend/model.h5')
try:
    model = tf.keras.models.load_model(MODEL_PATH)
except Exception as e:
    model = None
    print(f'Error loading model: {e}')

class PredictRequest(BaseModel):
    data: list  # shape: [sequence_length, n_features]

@app.post('/predict')
def predict(req: PredictRequest):
    if model is None:
        raise HTTPException(status_code=500, detail='Model not loaded')
    try:
        X = np.array(req.data).reshape((1, len(req.data), -1))
        prediction = model.predict(X)
        return {'prediction': float(prediction[0][0])}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) 