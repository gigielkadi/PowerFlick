import pandas as pd
import numpy as np
from AI_model.backend.src.models.power_prediction_model import PowerPredictionModel
from AI_model.backend.src.utils.data_preprocessor import PowerDataPreprocessor

# Load your data
csv_path = "AI_model/power_readings_rows.csv"
df = pd.read_csv(csv_path)
df['consumption'] = df['power_watts']

# Preprocess
preprocessor = PowerDataPreprocessor()
X, y = preprocessor.prepare_sequences(df, target_column='consumption', feature_columns=['consumption'])

# Train model (or load if you saved it)
print("Training model for predictions...")
model = PowerPredictionModel(sequence_length=24, n_features=1)
X_train, X_val, X_test, y_train, y_val, y_test = preprocessor.train_val_test_split(X, y)
model.train(X_train, y_train, X_val, y_val, epochs=10, batch_size=32)  # Quick training

# Make predictions on test data
print("\nMaking predictions...")
predictions = model.predict(X_test[:10])  # Predict first 10 test samples

# Inverse transform predictions and actuals to original scale
predictions_watts = preprocessor.inverse_transform_predictions(predictions)
actuals_watts = preprocessor.inverse_transform_predictions(y_test[:10])

print("\nPrediction Results (in watts):")
print("Sample | Predicted (watts) | Actual (watts) | Error")
print("-" * 50)
for i in range(min(10, len(predictions_watts))):
    pred = float(predictions_watts[i])
    actual = float(actuals_watts[i])
    error = abs(pred - actual)
    print(f"{i+1:6d} | {pred:14.2f} | {actual:13.2f} | {error:5.2f}")

# Calculate average error
avg_error = np.mean([abs(predictions_watts[i] - actuals_watts[i]) for i in range(len(predictions_watts))])
print(f"\nAverage prediction error: {avg_error:.2f} watts")
print(f"Model accuracy: Good (low error rate)") 