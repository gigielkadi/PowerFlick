import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
from tensorflow.keras.optimizers import Adam
import numpy as np
from typing import Tuple, List

class PowerPredictionModel:
    def __init__(
        self,
        sequence_length: int = 24,
        n_features: int = 1,
        lstm_units: int = 64,
        dropout_rate: float = 0.2,
        learning_rate: float = 0.001,
    ):
        self.sequence_length = sequence_length
        self.n_features = n_features
        self.model = self._build_model(lstm_units, dropout_rate, learning_rate)

    def _build_model(
        self,
        lstm_units: int,
        dropout_rate: float,
        learning_rate: float,
    ) -> Sequential:
        model = Sequential([
            LSTM(
                lstm_units,
                activation='relu',
                input_shape=(self.sequence_length, self.n_features),
                return_sequences=True,
            ),
            Dropout(dropout_rate),
            LSTM(lstm_units // 2, activation='relu'),
            Dropout(dropout_rate),
            Dense(32, activation='relu'),
            Dense(1)
        ])

        model.compile(
            optimizer=Adam(learning_rate=learning_rate),
            loss='mse',
            metrics=['mae', 'mse']
        )

        return model

    def train(
        self,
        X_train: np.ndarray,
        y_train: np.ndarray,
        X_val: np.ndarray,
        y_val: np.ndarray,
        epochs: int = 100,
        batch_size: int = 32,
        patience: int = 10,
    ) -> tf.keras.callbacks.History:
        early_stopping = tf.keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=patience,
            restore_best_weights=True
        )

        history = self.model.fit(
            X_train,
            y_train,
            validation_data=(X_val, y_val),
            epochs=epochs,
            batch_size=batch_size,
            callbacks=[early_stopping],
            verbose=1
        )

        return history

    def predict(self, X: np.ndarray) -> np.ndarray:
        return self.model.predict(X)

    def evaluate(
        self,
        X_test: np.ndarray,
        y_test: np.ndarray
    ) -> Tuple[float, float, float]:
        mse, mae, _ = self.model.evaluate(X_test, y_test, verbose=0)
        rmse = np.sqrt(mse)
        return mse, rmse, mae

    def detect_anomalies(
        self,
        X: np.ndarray,
        y_true: np.ndarray,
        threshold: float = 2.0
    ) -> List[dict]:
        predictions = self.predict(X)
        errors = np.abs(predictions - y_true)
        mean_error = np.mean(errors)
        std_error = np.std(errors)
        
        anomalies = []
        for i, error in enumerate(errors):
            if error > mean_error + threshold * std_error:
                anomalies.append({
                    'index': i,
                    'actual': float(y_true[i]),
                    'predicted': float(predictions[i]),
                    'error': float(error),
                    'severity': 'high' if error > mean_error + 3 * std_error else 'medium'
                })
        
        return anomalies

    def save(self, path: str):
        self.model.save(path)

    @classmethod
    def load(cls, path: str) -> 'PowerPredictionModel':
        model = tf.keras.models.load_model(path)
        instance = cls()
        instance.model = model
        return instance 