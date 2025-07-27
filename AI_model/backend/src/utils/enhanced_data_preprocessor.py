import numpy as np
import pandas as pd
from typing import Tuple, List, Dict, Optional
from sklearn.preprocessing import MinMaxScaler, StandardScaler, RobustScaler
from sklearn.ensemble import IsolationForest
from sklearn.decomposition import PCA
import warnings
warnings.filterwarnings('ignore')

class EnhancedDataPreprocessor:
    """
    Advanced data preprocessor with multi-feature support:
    - Weather data integration
    - Time-based feature engineering
    - Advanced anomaly detection
    - Multiple scaling strategies
    """
    
    def __init__(self, scaling_method: str = 'robust'):
        self.power_scaler = self._get_scaler(scaling_method)
        self.context_scaler = self._get_scaler(scaling_method)
        self.anomaly_detector = IsolationForest(contamination=0.1, random_state=42)
        self.pca = PCA(n_components=0.95)  # Keep 95% of variance
        
    def _get_scaler(self, method: str):
        """Get scaler based on method"""
        scalers = {
            'minmax': MinMaxScaler(),
            'standard': StandardScaler(),
            'robust': RobustScaler()
        }
        return scalers.get(method, RobustScaler())

    def add_time_features(self, df: pd.DataFrame, timestamp_col: str = 'timestamp') -> pd.DataFrame:
        """Add comprehensive time-based features"""
        df = df.copy()
        df[timestamp_col] = pd.to_datetime(df[timestamp_col])
        
        # Basic time features
        df['hour'] = df[timestamp_col].dt.hour
        df['day_of_week'] = df[timestamp_col].dt.dayofweek
        df['day_of_month'] = df[timestamp_col].dt.day
        df['month'] = df[timestamp_col].dt.month
        df['quarter'] = df[timestamp_col].dt.quarter
        df['is_weekend'] = (df['day_of_week'] >= 5).astype(int)
        
        # Cyclical encoding for time features
        df['hour_sin'] = np.sin(2 * np.pi * df['hour'] / 24)
        df['hour_cos'] = np.cos(2 * np.pi * df['hour'] / 24)
        df['day_sin'] = np.sin(2 * np.pi * df['day_of_week'] / 7)
        df['day_cos'] = np.cos(2 * np.pi * df['day_of_week'] / 7)
        df['month_sin'] = np.sin(2 * np.pi * df['month'] / 12)
        df['month_cos'] = np.cos(2 * np.pi * df['month'] / 12)
        
        # Peak hours (7-9 AM, 6-8 PM)
        df['is_morning_peak'] = ((df['hour'] >= 7) & (df['hour'] <= 9)).astype(int)
        df['is_evening_peak'] = ((df['hour'] >= 18) & (df['hour'] <= 20)).astype(int)
        df['is_peak_hour'] = (df['is_morning_peak'] | df['is_evening_peak']).astype(int)
        
        # Sleep hours (11 PM - 6 AM)
        df['is_sleep_hour'] = ((df['hour'] >= 23) | (df['hour'] <= 6)).astype(int)
        
        # Work hours (9 AM - 5 PM on weekdays)
        df['is_work_hour'] = (
            (df['hour'] >= 9) & (df['hour'] <= 17) & (df['day_of_week'] < 5)
        ).astype(int)
        
        return df

    def add_weather_features(self, df: pd.DataFrame, weather_data: Optional[pd.DataFrame] = None) -> pd.DataFrame:
        """Add weather-based features (mock implementation - integrate with weather API)"""
        df = df.copy()
        
        if weather_data is not None:
            # Merge with actual weather data
            df = df.merge(weather_data, on='timestamp', how='left')
        else:
            # Generate mock weather features for demonstration
            np.random.seed(42)
            df['temperature'] = 20 + 10 * np.sin(2 * np.pi * df['hour'] / 24) + np.random.normal(0, 2, len(df))
            df['humidity'] = 50 + 20 * np.random.random(len(df))
            df['cloud_cover'] = np.random.uniform(0, 100, len(df))
            
        # Weather-based features
        df['temp_category'] = pd.cut(df['temperature'], bins=[-np.inf, 10, 20, 30, np.inf], 
                                   labels=['cold', 'cool', 'warm', 'hot'])
        df['temp_cold'] = (df['temp_category'] == 'cold').astype(int)
        df['temp_hot'] = (df['temp_category'] == 'hot').astype(int)
        
        # Heating/cooling likely based on temperature
        df['heating_likely'] = (df['temperature'] < 15).astype(int)
        df['cooling_likely'] = (df['temperature'] > 25).astype(int)
        
        return df

    def add_lag_features(self, df: pd.DataFrame, target_col: str = 'power_watts', lags: List[int] = [1, 2, 6, 12, 24]) -> pd.DataFrame:
        """Add lagged features for temporal dependencies"""
        df = df.copy()
        df = df.sort_values('timestamp')
        
        for lag in lags:
            df[f'{target_col}_lag_{lag}'] = df[target_col].shift(lag)
            
        # Rolling statistics
        for window in [6, 12, 24]:
            df[f'{target_col}_rolling_mean_{window}'] = df[target_col].rolling(window=window).mean()
            df[f'{target_col}_rolling_std_{window}'] = df[target_col].rolling(window=window).std()
            df[f'{target_col}_rolling_min_{window}'] = df[target_col].rolling(window=window).min()
            df[f'{target_col}_rolling_max_{window}'] = df[target_col].rolling(window=window).max()
        
        # Exponential moving averages
        for alpha in [0.1, 0.3, 0.7]:
            df[f'{target_col}_ema_{alpha}'] = df[target_col].ewm(alpha=alpha).mean()
        
        return df

    def detect_and_handle_anomalies(self, df: pd.DataFrame, target_col: str = 'power_watts') -> Tuple[pd.DataFrame, List[int]]:
        """Detect and optionally handle anomalies"""
        df = df.copy()
        
        # Statistical anomaly detection
        Q1 = df[target_col].quantile(0.25)
        Q3 = df[target_col].quantile(0.75)
        IQR = Q3 - Q1
        lower_bound = Q1 - 1.5 * IQR
        upper_bound = Q3 + 1.5 * IQR
        
        statistical_anomalies = df[(df[target_col] < lower_bound) | (df[target_col] > upper_bound)].index.tolist()
        
        # Isolation Forest anomaly detection
        if len(df) > 50:  # Need sufficient data
            features_for_anomaly = [col for col in df.columns if col not in ['timestamp', 'device_id']]
            X_anomaly = df[features_for_anomaly].select_dtypes(include=[np.number]).fillna(0)
            
            if len(X_anomaly.columns) > 0:
                anomaly_scores = self.anomaly_detector.fit_predict(X_anomaly)
                ml_anomalies = df[anomaly_scores == -1].index.tolist()
            else:
                ml_anomalies = []
        else:
            ml_anomalies = []
        
        # Combine anomalies
        all_anomalies = list(set(statistical_anomalies + ml_anomalies))
        
        # Mark anomalies
        df['is_anomaly'] = 0
        df.loc[all_anomalies, 'is_anomaly'] = 1
        
        return df, all_anomalies

    def create_contextual_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """Create comprehensive contextual feature set"""
        df = self.add_time_features(df)
        df = self.add_weather_features(df)
        df = self.add_lag_features(df)
        df, anomalies = self.detect_and_handle_anomalies(df)
        
        # Device-specific patterns (if multiple devices)
        if 'device_id' in df.columns:
            device_stats = df.groupby('device_id')['power_watts'].agg(['mean', 'std']).reset_index()
            device_stats.columns = ['device_id', 'device_mean_power', 'device_std_power']
            df = df.merge(device_stats, on='device_id', how='left')
            
            # Relative power consumption
            df['power_relative_to_device_mean'] = df['power_watts'] / (df['device_mean_power'] + 1e-6)
        
        return df

    def prepare_enhanced_sequences(
        self,
        df: pd.DataFrame,
        sequence_length: int = 168,  # 1 week
        target_col: str = 'power_watts',
        prediction_horizons: List[int] = [1, 6, 24],
    ) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
        """
        Prepare sequences with multi-horizon targets and contextual features
        """
        # Create contextual features
        df_enhanced = self.create_contextual_features(df)
        df_enhanced = df_enhanced.dropna()
        
        if len(df_enhanced) < sequence_length + max(prediction_horizons):
            raise ValueError(f"Insufficient data. Need at least {sequence_length + max(prediction_horizons)} rows")
        
        # Separate power and contextual features
        power_features = [target_col]
        
        # Select contextual features (exclude target and metadata)
        exclude_cols = ['timestamp', 'device_id', target_col, 'is_anomaly', 'temp_category']
        contextual_features = [col for col in df_enhanced.columns 
                             if col not in exclude_cols and df_enhanced[col].dtype in ['int64', 'float64']]
        
        print(f"Power features: {power_features}")
        print(f"Contextual features ({len(contextual_features)}): {contextual_features[:10]}...")  # Show first 10
        
        # Scale features
        power_data = self.power_scaler.fit_transform(df_enhanced[power_features])
        
        if contextual_features:
            context_data = self.context_scaler.fit_transform(df_enhanced[contextual_features])
        else:
            # Create dummy contextual features if none available
            context_data = np.zeros((len(df_enhanced), 7))
            contextual_features = [f'dummy_feature_{i}' for i in range(7)]
        
        # Create sequences
        X_power, X_context = [], []
        y_1h, y_6h, y_24h = [], [], []
        
        for i in range(len(power_data) - sequence_length - max(prediction_horizons)):
            # Input sequences
            X_power.append(power_data[i:i + sequence_length])
            X_context.append(context_data[i:i + sequence_length])
            
            # Multi-horizon targets
            target_start = i + sequence_length
            
            # 1-hour prediction
            y_1h.append(power_data[target_start])
            
            # 6-hour predictions
            y_6h.append(power_data[target_start:target_start + 6].flatten())
            
            # 24-hour predictions
            y_24h.append(power_data[target_start:target_start + 24].flatten())
        
        return (
            np.array(X_power),
            np.array(X_context),
            np.array(y_1h),
            np.array(y_6h),
            np.array(y_24h)
        )

    def train_val_test_split_enhanced(
        self,
        X_power: np.ndarray,
        X_context: np.ndarray,
        y_1h: np.ndarray,
        y_6h: np.ndarray,
        y_24h: np.ndarray,
        train_ratio: float = 0.7,
        val_ratio: float = 0.15,
    ) -> Tuple:
        """Split data for training with time series considerations"""
        
        total_samples = len(X_power)
        train_end = int(total_samples * train_ratio)
        val_end = int(total_samples * (train_ratio + val_ratio))
        
        # Training set
        X_power_train = X_power[:train_end]
        X_context_train = X_context[:train_end]
        y_1h_train = y_1h[:train_end]
        y_6h_train = y_6h[:train_end]
        y_24h_train = y_24h[:train_end]
        
        # Validation set
        X_power_val = X_power[train_end:val_end]
        X_context_val = X_context[train_end:val_end]
        y_1h_val = y_1h[train_end:val_end]
        y_6h_val = y_6h[train_end:val_end]
        y_24h_val = y_24h[train_end:val_end]
        
        # Test set
        X_power_test = X_power[val_end:]
        X_context_test = X_context[val_end:]
        y_1h_test = y_1h[val_end:]
        y_6h_test = y_6h[val_end:]
        y_24h_test = y_24h[val_end:]
        
        return (
            X_power_train, X_context_train, y_1h_train, y_6h_train, y_24h_train,
            X_power_val, X_context_val, y_1h_val, y_6h_val, y_24h_val,
            X_power_test, X_context_test, y_1h_test, y_6h_test, y_24h_test
        )

    def inverse_transform_predictions(self, predictions: np.ndarray) -> np.ndarray:
        """Transform predictions back to original scale"""
        # Handle different prediction shapes
        if predictions.ndim == 1:
            predictions = predictions.reshape(-1, 1)
        elif predictions.ndim == 3:
            original_shape = predictions.shape
            predictions = predictions.reshape(-1, 1)
            result = self.power_scaler.inverse_transform(predictions)
            return result.reshape(original_shape)
        
        return self.power_scaler.inverse_transform(predictions)

    def prepare_prediction_data_enhanced(
        self,
        df: pd.DataFrame,
        sequence_length: int = 168,
        target_col: str = 'power_watts',
    ) -> Tuple[np.ndarray, np.ndarray]:
        """Prepare data for making predictions with contextual features"""
        
        # Create enhanced features
        df_enhanced = self.create_contextual_features(df)
        df_enhanced = df_enhanced.dropna()
        
        if len(df_enhanced) < sequence_length:
            raise ValueError(f'Not enough data points. Need at least {sequence_length}')
        
        # Use the most recent sequence
        recent_data = df_enhanced.tail(sequence_length)
        
        # Separate features
        power_features = [target_col]
        exclude_cols = ['timestamp', 'device_id', target_col, 'is_anomaly', 'temp_category']
        contextual_features = [col for col in recent_data.columns 
                             if col not in exclude_cols and recent_data[col].dtype in ['int64', 'float64']]
        
        # Scale features using existing scalers
        power_data = self.power_scaler.transform(recent_data[power_features])
        
        if contextual_features and hasattr(self.context_scaler, 'scale_'):
            context_data = self.context_scaler.transform(recent_data[contextual_features])
        else:
            # Use dummy features if contextual features not available
            context_data = np.zeros((len(recent_data), 7))
        
        return np.array([power_data]), np.array([context_data])

    def get_feature_importance_analysis(self, df: pd.DataFrame) -> Dict:
        """Analyze feature importance and correlations"""
        df_enhanced = self.create_contextual_features(df)
        df_numeric = df_enhanced.select_dtypes(include=[np.number])
        
        # Correlation analysis
        correlation_matrix = df_numeric.corr()
        target_correlations = correlation_matrix['power_watts'].abs().sort_values(ascending=False)
        
        # Feature statistics
        feature_stats = {
            'total_features': len(df_numeric.columns),
            'high_correlation_features': target_correlations[target_correlations > 0.1].to_dict(),
            'feature_means': df_numeric.mean().to_dict(),
            'feature_stds': df_numeric.std().to_dict(),
            'missing_value_counts': df_enhanced.isnull().sum().to_dict()
        }
        
        return feature_stats

    def generate_data_quality_report(self, df: pd.DataFrame) -> Dict:
        """Generate comprehensive data quality report"""
        report = {
            'total_records': len(df),
            'date_range': {
                'start': df['timestamp'].min().isoformat() if 'timestamp' in df.columns else None,
                'end': df['timestamp'].max().isoformat() if 'timestamp' in df.columns else None,
            },
            'missing_values': df.isnull().sum().to_dict(),
            'data_types': df.dtypes.astype(str).to_dict(),
            'anomaly_count': 0,  # Will be filled by anomaly detection
            'power_statistics': {
                'mean': float(df['power_watts'].mean()) if 'power_watts' in df.columns else None,
                'std': float(df['power_watts'].std()) if 'power_watts' in df.columns else None,
                'min': float(df['power_watts'].min()) if 'power_watts' in df.columns else None,
                'max': float(df['power_watts'].max()) if 'power_watts' in df.columns else None,
                'zero_values': int((df['power_watts'] == 0).sum()) if 'power_watts' in df.columns else None,
            }
        }
        
        # Detect anomalies and update count
        if 'power_watts' in df.columns:
            _, anomalies = self.detect_and_handle_anomalies(df)
            report['anomaly_count'] = len(anomalies)
        
        return report 