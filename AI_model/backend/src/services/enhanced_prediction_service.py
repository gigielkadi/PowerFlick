from datetime import datetime, timedelta
import numpy as np
import pandas as pd
from typing import Dict, List, Tuple, Optional
import asyncio
from concurrent.futures import ThreadPoolExecutor
import logging

from ..models.enhanced_power_prediction_model import EnhancedPowerPredictionModel
from ..utils.enhanced_data_preprocessor import EnhancedDataPreprocessor
from ..database.supabase_client import SupabaseClient

class EnhancedPredictionService:
    """
    Advanced prediction service with:
    - Multi-horizon predictions (1h, 6h, 24h)
    - Smart anomaly detection with confidence scores
    - Predictive insights and recommendations
    - Weather integration
    - Performance optimization
    """
    
    def __init__(
        self,
        model: EnhancedPowerPredictionModel,
        preprocessor: EnhancedDataPreprocessor,
        db_client: SupabaseClient,
        executor: Optional[ThreadPoolExecutor] = None
    ):
        self.model = model
        self.preprocessor = preprocessor
        self.db_client = db_client
        self.executor = executor or ThreadPoolExecutor(max_workers=4)
        self.logger = logging.getLogger(__name__)
        
        # Cache for frequent predictions
        self._prediction_cache = {}
        self._cache_expiry = {}

    async def predict_multi_horizon(
        self,
        device_id: str,
        horizons: List[str] = ['1h', '6h', '24h']
    ) -> Dict[str, List]:
        """
        Predict power consumption for multiple time horizons
        """
        try:
            # Check cache first
            cache_key = f"{device_id}_multi_horizon"
            if self._is_cache_valid(cache_key):
                return self._prediction_cache[cache_key]
            
            # Get recent data (1 week for context)
            end_time = datetime.now()
            start_time = end_time - timedelta(days=7)
            
            data = await self._get_data_async(device_id, start_time, end_time)
            
            if not data:
                raise ValueError('No recent data available for prediction')
            
            df = pd.DataFrame(data)
            
            # Prepare data for prediction
            X_power, X_context = self.preprocessor.prepare_prediction_data_enhanced(df)
            
            # Make predictions
            predictions = self.model.predict_multi_horizon(X_power, X_context)
            
            # Transform back to original scale
            predictions_transformed = {}
            for horizon, pred in predictions.items():
                predictions_transformed[horizon] = self.preprocessor.inverse_transform_predictions(pred)
            
            # Generate timestamps for each horizon
            result = {}
            for horizon in horizons:
                if horizon in predictions_transformed:
                    horizon_hours = int(horizon.replace('h', ''))
                    if horizon == '1h':
                        timestamps = [(end_time + timedelta(hours=1)).isoformat()]
                        values = [float(predictions_transformed[horizon][0][0])]
                    else:
                        timestamps = [
                            (end_time + timedelta(hours=i+1)).isoformat()
                            for i in range(horizon_hours)
                        ]
                        values = [float(v) for v in predictions_transformed[horizon][0]]
                    
                    result[horizon] = {
                        'predictions': [
                            {'timestamp': ts, 'value': val}
                            for ts, val in zip(timestamps, values)
                        ]
                    }
            
            # Detect anomalies in predictions
            anomalies = await self._detect_prediction_anomalies(device_id, predictions_transformed)
            result['anomalies'] = anomalies
            
            # Generate insights
            insights = await self._generate_predictive_insights(device_id, predictions_transformed, df)
            result['insights'] = insights
            
            # Cache result
            self._cache_result(cache_key, result, minutes=10)
            
            return result
            
        except Exception as e:
            self.logger.error(f"Error in multi-horizon prediction: {e}")
            raise

    async def _detect_prediction_anomalies(
        self,
        device_id: str,
        predictions: Dict[str, np.ndarray]
    ) -> List[Dict]:
        """
        Detect anomalies in predictions using historical patterns
        """
        try:
            # Get historical data for comparison
            end_time = datetime.now()
            start_time = end_time - timedelta(days=30)
            
            historical_data = await self._get_data_async(device_id, start_time, end_time)
            
            if not historical_data:
                return []
            
            df_historical = pd.DataFrame(historical_data)
            
            # Use the model for anomaly detection
            X_power, X_context = self.preprocessor.prepare_prediction_data_enhanced(df_historical)
            
            # Get prediction intervals and anomalies
            anomalies = self.model.detect_advanced_anomalies(
                X_power, X_context, predictions['1h'].flatten()
            )
            
            # Format anomalies for API response
            formatted_anomalies = []
            for anomaly in anomalies:
                formatted_anomalies.append({
                    'timestamp': (datetime.now() + timedelta(hours=anomaly['index'])).isoformat(),
                    'predicted_value': anomaly['predicted'],
                    'expected_range': {
                        'lower': anomaly['lower_bound'],
                        'upper': anomaly['upper_bound']
                    },
                    'uncertainty': anomaly['uncertainty'],
                    'severity': anomaly['severity'],
                    'confidence': anomaly['confidence'],
                    'type': 'prediction_anomaly'
                })
            
            return formatted_anomalies
            
        except Exception as e:
            self.logger.error(f"Error detecting prediction anomalies: {e}")
            return []

    async def _generate_predictive_insights(
        self,
        device_id: str,
        predictions: Dict[str, np.ndarray],
        current_data: pd.DataFrame
    ) -> List[Dict]:
        """
        Generate AI-powered insights and recommendations
        """
        insights = []
        
        try:
            # Extract prediction values
            pred_1h = float(predictions['1h'][0][0])
            pred_6h = predictions['6h'][0]
            pred_24h = predictions['24h'][0]
            
            current_power = float(current_data['power_watts'].iloc[-1])
            avg_power = float(current_data['power_watts'].mean())
            
            # 1. Immediate spike detection
            if pred_1h > current_power * 1.5:
                insights.append({
                    'type': 'immediate_spike',
                    'severity': 'high',
                    'title': 'Power Spike Predicted',
                    'description': f'Power consumption expected to increase by {((pred_1h/current_power - 1) * 100):.1f}% in the next hour.',
                    'recommendation': 'Monitor device usage and check for any unusual activity.',
                    'confidence': 0.85,
                    'timestamp': datetime.now().isoformat()
                })
            
            # 2. Peak load analysis
            peak_6h = np.max(pred_6h)
            peak_time = np.argmax(pred_6h) + 1
            
            if peak_6h > avg_power * 2:
                insights.append({
                    'type': 'peak_load',
                    'severity': 'medium',
                    'title': 'Peak Load Expected',
                    'description': f'Peak consumption of {peak_6h:.1f}W expected in {peak_time} hours.',
                    'recommendation': 'Consider deferring non-essential energy usage to reduce peak load.',
                    'confidence': 0.78,
                    'timestamp': datetime.now().isoformat()
                })
            
            # 3. Energy efficiency insights
            daily_prediction = np.sum(pred_24h)
            if daily_prediction > avg_power * 24 * 1.2:
                insights.append({
                    'type': 'efficiency',
                    'severity': 'low',
                    'title': 'High Energy Day Predicted',
                    'description': f'Tomorrow\'s consumption predicted to be {((daily_prediction/(avg_power*24) - 1) * 100):.1f}% above average.',
                    'recommendation': 'Review energy-intensive activities and optimize usage patterns.',
                    'confidence': 0.72,
                    'timestamp': datetime.now().isoformat()
                })
            
            # 4. Cost optimization
            cost_per_kwh = 0.12  # Example rate
            predicted_cost = daily_prediction * cost_per_kwh / 1000
            
            if predicted_cost > 5:  # Example threshold
                insights.append({
                    'type': 'cost_optimization',
                    'severity': 'medium',
                    'title': 'Cost Alert',
                    'description': f'Predicted daily cost: ${predicted_cost:.2f}',
                    'recommendation': 'Consider using energy-efficient settings or timing usage during off-peak hours.',
                    'confidence': 0.80,
                    'timestamp': datetime.now().isoformat()
                })
            
            # 5. Pattern recognition insights
            # Check for unusual patterns in 24h prediction
            hourly_variance = np.var(pred_24h)
            if hourly_variance > np.var(current_data['power_watts']) * 2:
                insights.append({
                    'type': 'pattern_anomaly',
                    'severity': 'medium',
                    'title': 'Unusual Pattern Detected',
                    'description': 'AI detected an unusual consumption pattern in the next 24 hours.',
                    'recommendation': 'Review scheduled activities and device operations.',
                    'confidence': 0.65,
                    'timestamp': datetime.now().isoformat()
                })
            
            return insights
            
        except Exception as e:
            self.logger.error(f"Error generating insights: {e}")
            return []

    async def get_prediction_explanation(
        self,
        device_id: str
    ) -> Dict:
        """
        Get explainable AI insights for predictions
        """
        try:
            # Get recent data
            end_time = datetime.now()
            start_time = end_time - timedelta(days=7)
            
            data = await self._get_data_async(device_id, start_time, end_time)
            
            if not data:
                return {'error': 'No data available for explanation'}
            
            df = pd.DataFrame(data)
            X_power, X_context = self.preprocessor.prepare_prediction_data_enhanced(df)
            
            # Get explanation from model
            explanation = self.model.explain_prediction(X_power, X_context)
            
            # Format explanation for frontend
            formatted_explanation = {
                'model_confidence': explanation['prediction_confidence'],
                'key_factors': {
                    'historical_consumption': explanation['power_importance'],
                    'contextual_factors': explanation['context_importance']
                },
                'explanation_text': self._generate_explanation_text(explanation),
                'timestamp': datetime.now().isoformat()
            }
            
            return formatted_explanation
            
        except Exception as e:
            self.logger.error(f"Error generating explanation: {e}")
            return {'error': str(e)}

    def _generate_explanation_text(self, explanation: Dict) -> str:
        """Generate human-readable explanation"""
        confidence = explanation['prediction_confidence']
        
        if confidence > 0.8:
            confidence_text = "high confidence"
        elif confidence > 0.6:
            confidence_text = "moderate confidence"
        else:
            confidence_text = "low confidence"
        
        # Identify most important factors
        power_importance = np.array(explanation['power_importance'])
        context_importance = np.array(explanation['context_importance'])
        
        most_important_power = np.argmax(power_importance)
        most_important_context = np.argmax(context_importance)
        
        explanation_text = f"""
        The AI model predicts with {confidence_text} based on your consumption patterns.
        
        Key factors influencing this prediction:
        • Historical consumption patterns (importance: {power_importance[most_important_power]:.2f})
        • Contextual factors like time of day and weather (importance: {context_importance[most_important_context]:.2f})
        
        This prediction is based on {len(power_importance)} hours of historical data and {len(context_importance)} contextual features.
        """
        
        return explanation_text.strip()

    async def optimize_energy_schedule(
        self,
        device_id: str,
        appliances: List[Dict],
        target_hours: int = 24
    ) -> Dict:
        """
        Optimize energy schedule based on predictions
        """
        try:
            # Get multi-horizon predictions
            predictions = await self.predict_multi_horizon(device_id, ['24h'])
            
            if '24h' not in predictions:
                return {'error': 'Could not get 24h predictions'}
            
            hourly_predictions = [p['value'] for p in predictions['24h']['predictions']]
            
            # Simple optimization: schedule high-energy tasks during low-prediction periods
            optimization_schedule = []
            
            for appliance in appliances:
                power_needed = appliance.get('power_watts', 0)
                duration = appliance.get('duration_hours', 1)
                
                # Find the best time slot
                best_start_hour = self._find_optimal_time_slot(
                    hourly_predictions, power_needed, duration
                )
                
                optimization_schedule.append({
                    'appliance': appliance['name'],
                    'recommended_start_time': (datetime.now() + timedelta(hours=best_start_hour)).isoformat(),
                    'duration_hours': duration,
                    'expected_power': power_needed,
                    'estimated_cost_savings': self._calculate_cost_savings(
                        hourly_predictions, best_start_hour, power_needed, duration
                    )
                })
            
            return {
                'schedule': optimization_schedule,
                'total_estimated_savings': sum(s['estimated_cost_savings'] for s in optimization_schedule),
                'optimization_confidence': 0.75,
                'timestamp': datetime.now().isoformat()
            }
            
        except Exception as e:
            self.logger.error(f"Error optimizing energy schedule: {e}")
            return {'error': str(e)}

    def _find_optimal_time_slot(
        self,
        hourly_predictions: List[float],
        power_needed: float,
        duration: int
    ) -> int:
        """Find the best time slot for energy-intensive tasks"""
        best_hour = 0
        lowest_impact = float('inf')
        
        for start_hour in range(len(hourly_predictions) - duration + 1):
            # Calculate total impact of running appliance during this time
            impact = sum(
                hourly_predictions[start_hour + i] + power_needed
                for i in range(duration)
            )
            
            if impact < lowest_impact:
                lowest_impact = impact
                best_hour = start_hour
        
        return best_hour

    def _calculate_cost_savings(
        self,
        hourly_predictions: List[float],
        start_hour: int,
        power_needed: float,
        duration: int
    ) -> float:
        """Calculate estimated cost savings from optimization"""
        cost_per_kwh = 0.12
        
        # Cost if run during peak hours (simplified)
        peak_cost = max(hourly_predictions) * power_needed * duration * cost_per_kwh / 1000
        
        # Cost if run during optimized hours
        optimized_cost = sum(
            hourly_predictions[start_hour + i] for i in range(duration)
        ) * power_needed * cost_per_kwh / 1000 / duration
        
        return max(0, peak_cost - optimized_cost)

    async def get_advanced_metrics(self, device_id: str) -> Dict:
        """
        Get advanced model performance metrics
        """
        try:
            # Get recent data
            end_time = datetime.now()
            start_time = end_time - timedelta(days=30)
            
            data = await self._get_data_async(device_id, start_time, end_time)
            
            if not data:
                return {'error': 'No data available for metrics'}
            
            df = pd.DataFrame(data)
            
            # Prepare data for evaluation
            X_power, X_context, y_1h, y_6h, y_24h = self.preprocessor.prepare_enhanced_sequences(df)
            
            if len(X_power) < 10:
                return {'error': 'Insufficient data for metrics calculation'}
            
            # Take a sample for evaluation
            sample_size = min(100, len(X_power))
            indices = np.random.choice(len(X_power), sample_size, replace=False)
            
            X_power_sample = X_power[indices]
            X_context_sample = X_context[indices]
            y_1h_sample = y_1h[indices]
            
            # Get predictions
            predictions = self.model.predict_multi_horizon(X_power_sample, X_context_sample)
            
            # Calculate metrics
            pred_1h = predictions['1h'].flatten()
            actual_1h = y_1h_sample.flatten()
            
            mse = np.mean((pred_1h - actual_1h) ** 2)
            mae = np.mean(np.abs(pred_1h - actual_1h))
            rmse = np.sqrt(mse)
            
            # Calculate accuracy (as 1 - normalized RMSE)
            value_range = np.max(actual_1h) - np.min(actual_1h)
            normalized_rmse = rmse / value_range if value_range > 0 else 0
            accuracy = max(0, 1 - normalized_rmse)
            
            # Additional metrics
            mape = np.mean(np.abs((actual_1h - pred_1h) / (actual_1h + 1e-6))) * 100
            
            # Prediction intervals coverage
            anomalies = self.model.detect_advanced_anomalies(
                X_power_sample, X_context_sample, actual_1h
            )
            
            return {
                'basic_metrics': {
                    'mse': float(mse),
                    'mae': float(mae),
                    'rmse': float(rmse),
                    'accuracy': float(accuracy),
                    'mape': float(mape)
                },
                'advanced_metrics': {
                    'prediction_interval_coverage': len(anomalies) / len(pred_1h),
                    'uncertainty_score': float(np.mean([a['uncertainty'] for a in anomalies])) if anomalies else 0,
                    'model_confidence': float(np.mean([a['confidence'] for a in anomalies])) if anomalies else 0.8
                },
                'data_quality': self.preprocessor.generate_data_quality_report(df),
                'timestamp': datetime.now().isoformat()
            }
            
        except Exception as e:
            self.logger.error(f"Error calculating advanced metrics: {e}")
            return {'error': str(e)}

    async def _get_data_async(self, device_id: str, start_time: datetime, end_time: datetime) -> List[Dict]:
        """Get data asynchronously"""
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(
            self.executor,
            self.db_client.fetch_consumption_data,
            device_id,
            start_time,
            end_time
        )

    def _is_cache_valid(self, cache_key: str, minutes: int = 10) -> bool:
        """Check if cache is valid"""
        if cache_key not in self._cache_expiry:
            return False
        
        expiry_time = self._cache_expiry[cache_key]
        return datetime.now() < expiry_time

    def _cache_result(self, cache_key: str, result: Dict, minutes: int = 10):
        """Cache result with expiry"""
        self._prediction_cache[cache_key] = result
        self._cache_expiry[cache_key] = datetime.now() + timedelta(minutes=minutes)

    def cleanup_cache(self):
        """Clean up expired cache entries"""
        current_time = datetime.now()
        expired_keys = [
            key for key, expiry in self._cache_expiry.items()
            if current_time >= expiry
        ]
        
        for key in expired_keys:
            self._prediction_cache.pop(key, None)
            self._cache_expiry.pop(key, None) 