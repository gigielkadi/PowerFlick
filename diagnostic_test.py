import pandas as pd
import numpy as np
from AI_model.backend.src.models.power_prediction_model import PowerPredictionModel
from AI_model.backend.src.utils.data_preprocessor import PowerDataPreprocessor

print("=== DIAGNOSTIC TEST FOR CONSTANT PREDICTIONS ===\n")

# Load your data
csv_path = "AI_model/power_readings_rows.csv"
df = pd.read_csv(csv_path)
df['consumption'] = df['power_watts']

print("1. DATA INSPECTION:")
print(f"   Data shape: {df.shape}")
print(f"   Power watts - Mean: {df['power_watts'].mean():.2f}, Std: {df['power_watts'].std():.2f}")
print(f"   Power watts - Min: {df['power_watts'].min():.2f}, Max: {df['power_watts'].max():.2f}")
print(f"   Power watts - First 10 values: {df['power_watts'].head(10).tolist()}")
print(f"   Power watts - Last 10 values: {df['power_watts'].tail(10).tolist()}")
print()

# Check for variance
if df['power_watts'].std() < 0.1:
    print("   ⚠️  WARNING: Very low variance in power_watts data!")
print()

# Preprocess
print("2. PREPROCESSING INSPECTION:")
preprocessor = PowerDataPreprocessor()
X, y = preprocessor.prepare_sequences(df, target_column='consumption', feature_columns=['consumption'])

print(f"   Sequences shape: X={X.shape}, y={y.shape}")
print(f"   Scaled y - Mean: {y.mean():.4f}, Std: {y.std():.4f}")
print(f"   Scaled y - Min: {y.min():.4f}, Max: {y.max():.4f}")
print(f"   First 10 scaled y values: {y[:10]}")
print()

# Check scaler
print("3. SCALER INSPECTION:")
print(f"   Scaler data min: {preprocessor.scaler.data_min_}")
print(f"   Scaler data max: {preprocessor.scaler.data_max_}")
print(f"   Scaler feature range: {preprocessor.scaler.feature_range}")
print()

# Split data
X_train, X_val, X_test, y_train, y_val, y_test = preprocessor.train_val_test_split(X, y)
print("4. DATA SPLIT INSPECTION:")
print(f"   Train: X={X_train.shape}, y={y_train.shape}")
print(f"   Val: X={X_val.shape}, y={y_val.shape}")
print(f"   Test: X={X_test.shape}, y={y_test.shape}")
print(f"   Train y - Mean: {y_train.mean():.4f}, Std: {y_train.std():.4f}")
print(f"   Test y - Mean: {y_test.mean():.4f}, Std: {y_test.std():.4f}")
print()

# Train model with detailed monitoring
print("5. MODEL TRAINING (5 epochs for quick test):")
model = PowerPredictionModel(sequence_length=24, n_features=1)
model.train(X_train, y_train, X_val, y_val, epochs=5, batch_size=32)
print()

# Make predictions and inspect at each step
print("6. PREDICTION INSPECTION:")
test_samples = X_test[:5]  # Take 5 samples
print(f"   Input shape: {test_samples.shape}")

# Raw predictions (scaled)
raw_predictions = model.predict(test_samples)
print(f"   Raw predictions (scaled): {raw_predictions.flatten()}")
print(f"   Raw predictions - Mean: {raw_predictions.mean():.4f}, Std: {raw_predictions.std():.4f}")

# Inverse transform predictions
predictions_watts = preprocessor.inverse_transform_predictions(raw_predictions)
print(f"   Inverse transformed predictions: {predictions_watts}")

# Inverse transform actuals
actuals_watts = preprocessor.inverse_transform_predictions(y_test[:5])
print(f"   Inverse transformed actuals: {actuals_watts}")
print()

# Check if the issue is in inverse transform
print("7. INVERSE TRANSFORM TEST:")
# Test with known values
test_scaled = np.array([0.0, 0.5, 1.0]).reshape(-1, 1)
test_inverse = preprocessor.inverse_transform_predictions(test_scaled.flatten())
print(f"   Test scaled [0.0, 0.5, 1.0] -> inverse: {test_inverse}")
print()

print("8. DIAGNOSIS:")
if raw_predictions.std() < 0.001:
    print("   🔴 ISSUE: Model is predicting constant values (raw predictions have no variance)")
    print("   💡 Solution: Model underfitting - increase epochs, complexity, or check data")
elif predictions_watts.std() < 0.1:
    print("   🔴 ISSUE: Inverse transform is mapping to constant values")
    print("   💡 Solution: Check scaler fitting or data range")
else:
    print("   ✅ Model predictions have variance - check data quality or model complexity") 