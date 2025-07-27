from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime, timedelta
from typing import Dict, List
import numpy as np
import uvicorn
import os

# Initialize FastAPI app
app = FastAPI(
    title="PowerFlick AI API (Simplified)",
    description="Simplified AI API for testing connections",
    version="1.0.0",
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {
        "message": "PowerFlick AI API is running!",
        "status": "online",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/api/consumption/{device_id}")
async def get_consumption(device_id: str, start_date: str, end_date: str):
    """
    Mock consumption data endpoint
    """
    try:
        # Generate sample data for testing
        start = datetime.fromisoformat(start_date.replace('Z', '+00:00'))
        end = datetime.fromisoformat(end_date.replace('Z', '+00:00'))
        
        # Generate hourly sample data
        data = []
        current_time = start
        
        while current_time < end:
            # Create realistic power consumption pattern
            hour = current_time.hour
            base_power = 15  # Base consumption
            
            # Add daily pattern
            if 6 <= hour <= 8:  # Morning spike
                power = base_power + np.random.normal(10, 2)
            elif 18 <= hour <= 21:  # Evening spike
                power = base_power + np.random.normal(15, 3)
            elif 22 <= hour or hour <= 5:  # Night low
                power = base_power + np.random.normal(-5, 1)
            else:  # Day moderate
                power = base_power + np.random.normal(5, 2)
            
            power = max(0, power)  # Ensure non-negative
            
            data.append({
                "timestamp": current_time.isoformat(),
                "consumption": round(power, 2),
                "power_watts": round(power, 2)
            })
            
            current_time += timedelta(hours=1)
        
        return data[:168]  # Limit to 1 week of data
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating consumption data: {str(e)}")

@app.get("/api/predictions/{device_id}")
async def get_predictions(device_id: str):
    """
    Mock predictions endpoint
    """
    try:
        # Generate 24 hours of predictions
        predictions = []
        anomalies = []
        
        current_time = datetime.now()
        
        for i in range(24):
            pred_time = current_time + timedelta(hours=i+1)
            hour = pred_time.hour
            
            # Create realistic prediction pattern
            if 7 <= hour <= 9:  # Morning peak
                power = 20 + np.random.normal(5, 1)
            elif 18 <= hour <= 20:  # Evening peak
                power = 25 + np.random.normal(8, 2)
            elif 22 <= hour or hour <= 6:  # Night low
                power = 8 + np.random.normal(2, 0.5)
            else:  # Day moderate
                power = 15 + np.random.normal(3, 1)
            
            power = max(0, power)
            
            predictions.append({
                "timestamp": pred_time.isoformat(),
                "consumption": round(power, 2),
                "value": round(power, 2)
            })
            
            # Add occasional anomaly
            if np.random.random() < 0.1:  # 10% chance
                anomalies.append({
                    "timestamp": pred_time.isoformat(),
                    "value": round(power * 1.5, 2),
                    "deviation_percentage": 50.0,
                    "type": "high_deviation",
                    "severity": "medium"
                })
        
        return {
            "predictions": predictions,
            "anomalies": anomalies
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating predictions: {str(e)}")

@app.get("/api/model-metrics/{device_id}")
async def get_model_metrics(device_id: str):
    """
    Mock model metrics endpoint
    """
    try:
        # Return sample metrics
        return {
            "mse": 2.34,
            "rmse": 1.53,
            "mae": 1.12,
            "accuracy": 0.87,
            "last_trained": datetime.now().isoformat(),
            "status": "mock_data"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting model metrics: {str(e)}")

@app.post("/api/train-model/{device_id}")
async def train_model(device_id: str):
    """
    Mock model training endpoint
    """
    try:
        return {
            "message": "Model training completed (mock)",
            "mse": 2.10,
            "rmse": 1.45,
            "mae": 1.05,
            "accuracy": 0.89,
            "training_time": "45 seconds",
            "status": "success"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error training model: {str(e)}")

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "PowerFlick AI API",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0"
    }

if __name__ == "__main__":
    port = int(os.getenv("PORT", "8006"))  # Use 8006 to match Flutter app
    print(f"🚀 Starting PowerFlick AI API on port {port}")
    print(f"📊 Dashboard will connect to: http://localhost:{port}")
    print(f"🔗 Health check: http://localhost:{port}/health")
    
    uvicorn.run(
        "simple_api:app",
        host="0.0.0.0",
        port=port,
        reload=True,
        log_level="info"
    ) 