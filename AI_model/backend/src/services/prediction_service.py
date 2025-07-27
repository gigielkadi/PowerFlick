from datetime import datetime, timedelta
import numpy as np
import pandas as pd
from typing import Dict, List, Tuple

from ..models.power_prediction_model import PowerPredictionModel
from ..utils.data_preprocessor import PowerDataPreprocessor
from ..database.supabase_client import SupabaseClient

class PredictionService:
    def __init__(
        self,
        model: PowerPredictionModel,
        preprocessor: PowerDataPreprocessor,
        db_client: SupabaseClient,
    ):
        self.model = model
        self.preprocessor = preprocessor
        self.db_client = db_client

    async def predict_next_24h(
        self,
        device_id: str,
    ) -> Dict[str, List]:
        """
        Predict power consumption for the next 24 hours.
        """
        # Get recent data
        end_time = datetime.now()
        start_time = end_time - timedelta(hours=48)  # Get 48h of data for context
        
        data = self.db_client.fetch_consumption_data(
            device_id,
            start_time,
            end_time
        )
        
        if not data:
            raise ValueError('No recent data available for prediction')
            
        df = pd.DataFrame(data)
        
        # Prepare data for prediction
        X = self.preprocessor.prepare_prediction_data(df)
        
        # Make predictions
        predictions = self.model.predict(X)
        predictions = self.preprocessor.inverse_transform_predictions(predictions)
        
        # Generate timestamps for predictions
        timestamps = [
            (end_time + timedelta(hours=i)).isoformat()
            for i in range(1, 25)
        ]
        
        # Detect anomalies in predictions
        anomalies = self._detect_anomalies(predictions, df['power_watts'].values)
        
        return {
            'predictions': [
                {
                    'timestamp': timestamp,
                    'value': float(prediction)
                }
                for timestamp, prediction in zip(timestamps, predictions)
            ],
            'anomalies': anomalies
        }

    def _detect_anomalies(
        self,
        predictions: np.ndarray,
        recent_values: np.ndarray,
    ) -> List[Dict]:
        """
        Detect anomalies in predictions compared to recent values.
        """
        # Calculate mean and std of recent values
        mean_consumption = np.mean(recent_values)
        std_consumption = np.std(recent_values)
        
        anomalies = []
        for i, pred in enumerate(predictions):
            deviation = abs(pred - mean_consumption)
            if deviation > 2 * std_consumption:
                anomalies.append({
                    'timestamp': (datetime.now() + timedelta(hours=i+1)).isoformat(),
                    'value': float(pred),
                    'deviation_percentage': float(deviation / mean_consumption * 100),
                    'type': 'high_deviation' if pred > mean_consumption else 'low_deviation',
                    'severity': 'high' if deviation > 3 * std_consumption else 'medium'
                })
                
        return anomalies

    def get_prediction_accuracy(
        self,
        device_id: str,
    ) -> Dict[str, float]:
        """
        Calculate prediction accuracy metrics.
        """
        # Get data from the last week
        end_time = datetime.now()
        start_time = end_time - timedelta(days=7)
        
        data = self.db_client.fetch_consumption_data(
            device_id,
            start_time,
            end_time
        )
        
        if not data:
            raise ValueError('No data available for accuracy calculation')
            
        df = pd.DataFrame(data)
        
        # Prepare sequences
        X, y = self.preprocessor.prepare_sequences(df)
        
        # Get predictions
        predictions = self.model.predict(X)
        predictions = self.preprocessor.inverse_transform_predictions(predictions)
        actual = self.preprocessor.inverse_transform_predictions(y)
        
        # Calculate metrics
        mse = np.mean((predictions - actual) ** 2)
        rmse = np.sqrt(mse)
        mae = np.mean(np.abs(predictions - actual))
        
        # Calculate accuracy as 1 - normalized RMSE
        max_value = np.max(actual)
        min_value = np.min(actual)
        normalized_rmse = rmse / (max_value - min_value)
        accuracy = max(0, 1 - normalized_rmse)
        
        return {
            'mse': float(mse),
            'rmse': float(rmse),
            'mae': float(mae),
            'accuracy': float(accuracy)
        }

    def train(self, device_id: str) -> Dict[str, float]:
        """
        Train the model on recent data.
        """
        # Get training data (last 30 days)
        end_time = datetime.now()
        start_time = end_time - timedelta(days=30)
        
        data = self.db_client.fetch_consumption_data(
            device_id,
            start_time,
            end_time
        )
        
        if not data:
            raise ValueError('No data available for training')
            
        df = pd.DataFrame(data)
        
        # Prepare data
        X, y = self.preprocessor.prepare_sequences(df)
        X_train, X_val, X_test, y_train, y_val, y_test = \
            self.preprocessor.train_val_test_split(X, y)
        
        # Train model
        self.model.train(X_train, y_train, X_val, y_val)
        
        # Evaluate on test set
        mse, rmse, mae = self.model.evaluate(X_test, y_test)
        
        # Save metrics
        metrics = {
            'mse': float(mse),
            'rmse': float(rmse),
            'mae': float(mae),
            'timestamp': datetime.now().isoformat()
        }
        
        # await self.db_client.save_model_metrics(device_id, metrics)  # Skip for now
        
        return metrics 