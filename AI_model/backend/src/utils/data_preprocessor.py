import numpy as np
import pandas as pd
from typing import Tuple, List
from sklearn.preprocessing import MinMaxScaler

class PowerDataPreprocessor:
    def __init__(self):
        self.scaler = MinMaxScaler()

    def prepare_sequences(
        self,
        data: pd.DataFrame,
        sequence_length: int = 24,
        target_column: str = 'power_watts',
        feature_columns: List[str] = None,
    ) -> Tuple[np.ndarray, np.ndarray]:
        """
        Prepare sequences for LSTM model training.
        
        Args:
            data: DataFrame containing power consumption data
            sequence_length: Number of time steps in each sequence
            target_column: Name of the target column
            feature_columns: List of feature column names
            
        Returns:
            Tuple of (X, y) where X contains sequences and y contains targets
        """
        if feature_columns is None:
            feature_columns = [target_column]

        # Scale the features
        scaled_data = self.scaler.fit_transform(data[feature_columns])
        
        X, y = [], []
        for i in range(len(scaled_data) - sequence_length):
            X.append(scaled_data[i:(i + sequence_length)])
            y.append(scaled_data[i + sequence_length, 0])  # 0 index for target column
            
        return np.array(X), np.array(y)

    def train_val_test_split(
        self,
        X: np.ndarray,
        y: np.ndarray,
        train_ratio: float = 0.7,
        val_ratio: float = 0.15,
    ) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
        """
        Split data into training, validation, and test sets.
        
        Args:
            X: Input sequences
            y: Target values
            train_ratio: Proportion of data for training
            val_ratio: Proportion of data for validation
            
        Returns:
            Tuple of (X_train, X_val, X_test, y_train, y_val, y_test)
        """
        n = len(X)
        train_size = int(n * train_ratio)
        val_size = int(n * val_ratio)
        
        X_train = X[:train_size]
        y_train = y[:train_size]
        
        X_val = X[train_size:train_size + val_size]
        y_val = y[train_size:train_size + val_size]
        
        X_test = X[train_size + val_size:]
        y_test = y[train_size + val_size:]
        
        return X_train, X_val, X_test, y_train, y_val, y_test

    def inverse_transform_predictions(
        self,
        predictions: np.ndarray
    ) -> np.ndarray:
        """
        Transform scaled predictions back to original scale.
        
        Args:
            predictions: Scaled predictions from the model
            
        Returns:
            Predictions in original scale
        """
        # Reshape predictions to 2D array if necessary
        if len(predictions.shape) == 1:
            predictions = predictions.reshape(-1, 1)
            
        # Create dummy array for other features (if any)
        dummy = np.zeros((len(predictions), self.scaler.n_features_in_))
        dummy[:, 0] = predictions[:, 0]
        
        # Inverse transform
        return self.scaler.inverse_transform(dummy)[:, 0]

    def prepare_prediction_data(
        self,
        data: pd.DataFrame,
        sequence_length: int = 24,
        feature_columns: List[str] = None,
    ) -> np.ndarray:
        """
        Prepare data for making predictions.
        
        Args:
            data: DataFrame containing recent power consumption data
            sequence_length: Number of time steps in each sequence
            feature_columns: List of feature column names
            
        Returns:
            Scaled and formatted input sequence
        """
        if feature_columns is None:
            feature_columns = ['power_watts']
            
        if len(data) < sequence_length:
            raise ValueError(
                f'Not enough data points. Need at least {sequence_length}, '
                f'but got {len(data)}'
            )
            
        # Use the last sequence_length points
        recent_data = data.tail(sequence_length)
        
        # Fit the scaler on the recent data if not fitted
        if not hasattr(self.scaler, 'scale_'):
            self.scaler.fit(data[feature_columns])
        
        scaled_data = self.scaler.transform(recent_data[feature_columns])
        
        return np.array([scaled_data]) 