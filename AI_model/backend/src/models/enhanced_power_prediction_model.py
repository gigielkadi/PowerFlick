import tensorflow as tf
from tensorflow.keras.models import Model
from tensorflow.keras.layers import (
    Input, LSTM, Dense, Dropout, MultiHeadAttention, 
    LayerNormalization, GlobalAveragePooling1D, Concatenate,
    Conv1D, MaxPooling1D, Flatten, BatchNormalization
)
from tensorflow.keras.optimizers import Adam
import numpy as np
from typing import Tuple, List, Dict

class EnhancedPowerPredictionModel:
    """
    Advanced power prediction model with hybrid architecture:
    - Transformer attention for long-term dependencies
    - CNN for pattern recognition
    - LSTM for temporal modeling
    - Multi-feature input support (weather, time features, etc.)
    """
    
    def __init__(
        self,
        sequence_length: int = 168,  # 1 week of hourly data
        n_power_features: int = 1,
        n_contextual_features: int = 7,  # time, weather, etc.
        lstm_units: int = 128,
        transformer_heads: int = 8,
        transformer_layers: int = 2,
        cnn_filters: int = 64,
        dropout_rate: float = 0.2,
        learning_rate: float = 0.001,
    ):
        self.sequence_length = sequence_length
        self.n_power_features = n_power_features
        self.n_contextual_features = n_contextual_features
        self.model = self._build_hybrid_model(
            lstm_units, transformer_heads, transformer_layers,
            cnn_filters, dropout_rate, learning_rate
        )

    def _build_hybrid_model(
        self,
        lstm_units: int,
        transformer_heads: int,
        transformer_layers: int,
        cnn_filters: int,
        dropout_rate: float,
        learning_rate: float,
    ) -> Model:
        """Build hybrid transformer-CNN-LSTM model"""
        
        # Input layers
        power_input = Input(shape=(self.sequence_length, self.n_power_features), name='power_input')
        context_input = Input(shape=(self.sequence_length, self.n_contextual_features), name='context_input')
        
        # CNN branch for pattern recognition
        cnn_branch = self._build_cnn_branch(power_input, cnn_filters, dropout_rate)
        
        # Transformer branch for attention mechanisms
        transformer_branch = self._build_transformer_branch(
            power_input, transformer_heads, transformer_layers, dropout_rate
        )
        
        # LSTM branch for temporal modeling
        lstm_branch = self._build_lstm_branch(power_input, lstm_units, dropout_rate)
        
        # Context processing
        context_branch = self._build_context_branch(context_input, dropout_rate)
        
        # Combine all branches
        combined = Concatenate()([cnn_branch, transformer_branch, lstm_branch, context_branch])
        
        # Final prediction layers
        x = Dense(256, activation='relu')(combined)
        x = Dropout(dropout_rate)(x)
        x = Dense(128, activation='relu')(x)
        x = Dropout(dropout_rate)(x)
        x = Dense(64, activation='relu')(x)
        
        # Multi-horizon output (1h, 6h, 24h predictions)
        output_1h = Dense(1, name='1h_prediction')(x)
        output_6h = Dense(6, name='6h_prediction')(x)
        output_24h = Dense(24, name='24h_prediction')(x)
        
        model = Model(
            inputs=[power_input, context_input],
            outputs=[output_1h, output_6h, output_24h]
        )
        
        model.compile(
            optimizer=Adam(learning_rate=learning_rate),
            loss={
                '1h_prediction': 'mse',
                '6h_prediction': 'mse',
                '24h_prediction': 'mse'
            },
            loss_weights={
                '1h_prediction': 3.0,  # Higher weight for short-term accuracy
                '6h_prediction': 2.0,
                '24h_prediction': 1.0
            },
            metrics=['mae', 'mse']
        )
        
        return model

    def _build_cnn_branch(self, input_layer, filters: int, dropout_rate: float):
        """CNN branch for pattern recognition"""
        x = Conv1D(filters, 3, activation='relu', padding='same')(input_layer)
        x = BatchNormalization()(x)
        x = MaxPooling1D(2)(x)
        x = Dropout(dropout_rate)(x)
        
        x = Conv1D(filters // 2, 3, activation='relu', padding='same')(x)
        x = BatchNormalization()(x)
        x = MaxPooling1D(2)(x)
        x = Dropout(dropout_rate)(x)
        
        x = GlobalAveragePooling1D()(x)
        return Dense(64, activation='relu')(x)

    def _build_transformer_branch(self, input_layer, heads: int, layers: int, dropout_rate: float):
        """Transformer branch with self-attention"""
        x = input_layer
        
        for _ in range(layers):
            # Multi-head attention
            attention_output = MultiHeadAttention(
                num_heads=heads,
                key_dim=64,
                dropout=dropout_rate
            )(x, x)
            
            # Add & norm
            x = LayerNormalization()(x + attention_output)
            
            # Feed forward
            ff_output = Dense(256, activation='relu')(x)
            ff_output = Dropout(dropout_rate)(ff_output)
            ff_output = Dense(input_layer.shape[-1])(ff_output)
            
            # Add & norm
            x = LayerNormalization()(x + ff_output)
        
        x = GlobalAveragePooling1D()(x)
        return Dense(64, activation='relu')(x)

    def _build_lstm_branch(self, input_layer, units: int, dropout_rate: float):
        """LSTM branch for temporal modeling"""
        x = LSTM(units, return_sequences=True, dropout=dropout_rate)(input_layer)
        x = LSTM(units // 2, dropout=dropout_rate)(x)
        return Dense(64, activation='relu')(x)

    def _build_context_branch(self, input_layer, dropout_rate: float):
        """Process contextual features (time, weather, etc.)"""
        x = Dense(128, activation='relu')(input_layer)
        x = Dropout(dropout_rate)(x)
        x = Dense(64, activation='relu')(x)
        x = GlobalAveragePooling1D()(x)
        return Dense(32, activation='relu')(x)

    def train_with_validation(
        self,
        X_power: np.ndarray,
        X_context: np.ndarray,
        y_1h: np.ndarray,
        y_6h: np.ndarray,
        y_24h: np.ndarray,
        validation_data: Tuple,
        epochs: int = 100,
        batch_size: int = 32,
        patience: int = 15,
    ):
        """Train with early stopping and learning rate scheduling"""
        
        callbacks = [
            tf.keras.callbacks.EarlyStopping(
                monitor='val_loss',
                patience=patience,
                restore_best_weights=True
            ),
            tf.keras.callbacks.ReduceLROnPlateau(
                monitor='val_loss',
                factor=0.5,
                patience=patience//2,
                min_lr=1e-7
            ),
            tf.keras.callbacks.ModelCheckpoint(
                'best_model.h5',
                monitor='val_loss',
                save_best_only=True
            )
        ]
        
        history = self.model.fit(
            {'power_input': X_power, 'context_input': X_context},
            {'1h_prediction': y_1h, '6h_prediction': y_6h, '24h_prediction': y_24h},
            validation_data=validation_data,
            epochs=epochs,
            batch_size=batch_size,
            callbacks=callbacks,
            verbose=1
        )
        
        return history

    def predict_multi_horizon(self, X_power: np.ndarray, X_context: np.ndarray) -> Dict[str, np.ndarray]:
        """Make predictions for multiple time horizons"""
        predictions = self.model.predict({'power_input': X_power, 'context_input': X_context})
        
        return {
            '1h': predictions[0],
            '6h': predictions[1],
            '24h': predictions[2]
        }

    def detect_advanced_anomalies(
        self,
        X_power: np.ndarray,
        X_context: np.ndarray,
        y_true: np.ndarray,
        confidence_threshold: float = 0.95
    ) -> List[Dict]:
        """Advanced anomaly detection with prediction intervals"""
        
        # Monte Carlo dropout for uncertainty estimation
        predictions = []
        for _ in range(100):
            pred = self.model.predict({'power_input': X_power, 'context_input': X_context}, training=True)
            predictions.append(pred[0])  # 1h predictions
        
        predictions = np.array(predictions)
        mean_pred = np.mean(predictions, axis=0)
        std_pred = np.std(predictions, axis=0)
        
        # Calculate prediction intervals
        z_score = 1.96  # 95% confidence
        upper_bound = mean_pred + z_score * std_pred
        lower_bound = mean_pred - z_score * std_pred
        
        anomalies = []
        for i, (actual, pred, ub, lb, uncertainty) in enumerate(
            zip(y_true, mean_pred.flatten(), upper_bound.flatten(), lower_bound.flatten(), std_pred.flatten())
        ):
            if actual > ub or actual < lb:
                severity = 'high' if uncertainty > np.percentile(std_pred, 75) else 'medium'
                anomalies.append({
                    'index': i,
                    'actual': float(actual),
                    'predicted': float(pred),
                    'upper_bound': float(ub),
                    'lower_bound': float(lb),
                    'uncertainty': float(uncertainty),
                    'severity': severity,
                    'confidence': float(1 - (uncertainty / np.max(std_pred)))
                })
        
        return anomalies

    def explain_prediction(self, X_power: np.ndarray, X_context: np.ndarray) -> Dict:
        """Generate prediction explanations using integrated gradients"""
        # Simplified feature importance
        baseline_power = np.zeros_like(X_power)
        baseline_context = np.zeros_like(X_context)
        
        with tf.GradientTape() as tape:
            tape.watch([X_power, X_context])
            predictions = self.model({'power_input': X_power, 'context_input': X_context})
            
        gradients = tape.gradient(predictions[0], [X_power, X_context])
        
        return {
            'power_importance': np.mean(np.abs(gradients[0]), axis=0).tolist(),
            'context_importance': np.mean(np.abs(gradients[1]), axis=0).tolist(),
            'prediction_confidence': float(np.mean(predictions[0]))
        }

    def save_enhanced(self, path: str):
        """Save model with metadata"""
        self.model.save(path)
        
        # Save model metadata
        metadata = {
            'sequence_length': self.sequence_length,
            'n_power_features': self.n_power_features,
            'n_contextual_features': self.n_contextual_features,
            'model_type': 'enhanced_hybrid',
            'version': '2.0'
        }
        
        import json
        with open(f"{path}_metadata.json", 'w') as f:
            json.dump(metadata, f, indent=2)

    @classmethod
    def load_enhanced(cls, path: str) -> 'EnhancedPowerPredictionModel':
        """Load model with metadata"""
        model = tf.keras.models.load_model(path)
        
        # Load metadata
        import json
        try:
            with open(f"{path}_metadata.json", 'r') as f:
                metadata = json.load(f)
        except FileNotFoundError:
            # Default metadata if not found
            metadata = {
                'sequence_length': 168,
                'n_power_features': 1,
                'n_contextual_features': 7
            }
        
        instance = cls(
            sequence_length=metadata['sequence_length'],
            n_power_features=metadata['n_power_features'],
            n_contextual_features=metadata['n_contextual_features']
        )
        instance.model = model
        return instance 