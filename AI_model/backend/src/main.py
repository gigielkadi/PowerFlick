import os
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv

from .models.power_prediction_model import PowerPredictionModel
from .utils.data_preprocessor import PowerDataPreprocessor
from .database.supabase_client import SupabaseClient
from .services.prediction_service import PredictionService

# Load environment variables
load_dotenv()

# Initialize FastAPI app
app = FastAPI(
    title="Power Consumption AI API",
    description="AI-powered power consumption monitoring and prediction API",
    version="1.0.0",
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize services
model = PowerPredictionModel()
preprocessor = PowerDataPreprocessor()
db_client = SupabaseClient()
prediction_service = PredictionService(model, preprocessor, db_client)

# Pydantic models for request/response validation
class ConsumptionData(BaseModel):
    device_id: str
    timestamp: datetime
    consumption: float
    predicted_consumption: Optional[float] = None

class PredictionResponse(BaseModel):
    predictions: List[Dict]
    anomalies: List[Dict]

class ModelMetrics(BaseModel):
    mse: float
    rmse: float
    mae: float
    accuracy: float

@app.get("/")
async def root():
    return {"message": "Power Consumption AI API is running"}

@app.post("/api/consumption/{device_id}")
async def save_consumption(device_id: str, data: ConsumptionData):
    """
    Save power consumption data point.
    """
    try:
        result = db_client.save_consumption_data(
            device_id=device_id,
            timestamp=data.timestamp,
            consumption=data.consumption,
            predicted_consumption=data.predicted_consumption,
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/consumption/{device_id}")
async def get_consumption(
    device_id: str,
    start_date: datetime,
    end_date: datetime,
):
    """
    Get power consumption data for a device within a time range.
    """
    try:
        data = db_client.fetch_consumption_data(
            device_id,
            start_date,
            end_date,
        )
        return data
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/predictions/{device_id}")
async def get_predictions(device_id: str):
    """
    Get power consumption predictions for the next 24 hours.
    """
    try:
        predictions = await prediction_service.predict_next_24h(device_id)
        return predictions
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/model-metrics/{device_id}")
async def get_model_metrics(device_id: str):
    """
    Get model performance metrics.
    """
    try:
        metrics = prediction_service.get_prediction_accuracy(device_id)
        return metrics
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/train-model/{device_id}")
async def train_model(device_id: str):
    """
    Train the model on recent data.
    """
    try:
        metrics = prediction_service.train(device_id)
        return metrics
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=int(os.getenv("PORT", "8000")),
        reload=True
    ) 