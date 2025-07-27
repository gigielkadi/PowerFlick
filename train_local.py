import pandas as pd
from AI_model.backend.src.models.power_prediction_model import PowerPredictionModel
from AI_model.backend.src.utils.data_preprocessor import PowerDataPreprocessor

# Path to your CSV file
csv_path = "AI_model/power_readings_rows.csv"

# Load data
print("Loading data from CSV...")
df = pd.read_csv(csv_path)

# If your CSV does not have device_id, add a dummy one for compatibility
if 'device_id' not in df.columns:
    df['device_id'] = 'local_device'

# Use power_watts as the target
# Rename for compatibility with preprocessor (expects 'consumption')
df['consumption'] = df['power_watts']

# Preprocess data
preprocessor = PowerDataPreprocessor()
X, y = preprocessor.prepare_sequences(df, target_column='consumption', feature_columns=['consumption'])
X_train, X_val, X_test, y_train, y_val, y_test = preprocessor.train_val_test_split(X, y)

# Train model
print("Training LSTM model...")
model = PowerPredictionModel(sequence_length=24, n_features=1)
model.train(X_train, y_train, X_val, y_val, epochs=50, batch_size=32)

# Evaluate
mse, rmse, mae = model.evaluate(X_test, y_test)
print(f"Evaluation on test set: MSE={mse}, RMSE={rmse}, MAE={mae}")

# Optionally save the model
# model.save("AI_model/backend/model_local.h5")
print("Training complete. Model is in memory.") 