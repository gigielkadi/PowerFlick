#!/usr/bin/env python3
import requests
import pandas as pd
import json
from datetime import datetime
import sys

# Configuration
API_BASE = "http://localhost:8006"
DEVICE_ID = "d2ab803a-1742-46be-84c9-a20868642bc2"
CSV_FILE = "/Users/seifkhaled/Development/projects/powerflick_ copy 12/AI_model/power_readings_rows.csv"

def upload_csv_data():
    """Upload CSV data to the API"""
    print("📊 Loading CSV data...")
    
    try:
        # Read CSV file
        df = pd.read_csv(CSV_FILE)
        print(f"✅ Loaded {len(df)} records from CSV")
        
        # Show sample data
        print("\n📋 Sample data:")
        print(df.head(3)[['device_id', 'power_watts', 'timestamp']].to_string())
        
        successful_uploads = 0
        failed_uploads = 0
        
        print(f"\n🚀 Uploading {len(df)} records to API...")
        
        # Upload each row
        for index, row in df.iterrows():
            try:
                # Prepare data for API
                data = {
                    "device_id": str(row['device_id']),
                    "timestamp": str(row['timestamp']),
                    "consumption": float(row['power_watts'])
                }
                
                # Upload to API
                response = requests.post(f"{API_BASE}/api/consumption/{DEVICE_ID}", json=data)
                
                if response.status_code == 200:
                    successful_uploads += 1
                    if successful_uploads % 100 == 0:
                        print(f"✅ Uploaded {successful_uploads} records...")
                else:
                    failed_uploads += 1
                    if failed_uploads < 5:  # Show first few errors
                        print(f"❌ Failed record {index}: {response.status_code} - {response.text[:100]}")
                    
            except Exception as e:
                failed_uploads += 1
                if failed_uploads < 5:
                    print(f"❌ Error processing record {index}: {str(e)[:100]}")
        
        print(f"\n📈 Upload Summary:")
        print(f"✅ Successful: {successful_uploads}")
        print(f"❌ Failed: {failed_uploads}")
        print(f"📊 Total: {len(df)}")
        
        return successful_uploads > 0
        
    except Exception as e:
        print(f"❌ Error loading CSV: {e}")
        return False

def train_model():
    """Train the AI model with uploaded data"""
    print("\n🤖 Training AI model...")
    
    try:
        response = requests.post(f"{API_BASE}/api/train-model/{DEVICE_ID}")
        
        if response.status_code == 200:
            metrics = response.json()
            print("✅ Model training completed!")
            print(f"📊 Training Metrics:")
            print(f"   Accuracy: {metrics.get('accuracy', 0)*100:.1f}%")
            print(f"   RMSE: {metrics.get('rmse', 0):.2f}")
            print(f"   MAE: {metrics.get('mae', 0):.2f}")
            print(f"   MSE: {metrics.get('mse', 0):.2f}")
            return True
        else:
            print(f"❌ Training failed: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Training error: {e}")
        return False

def test_predictions():
    """Test the trained model with predictions"""
    print("\n🔮 Testing predictions...")
    
    try:
        response = requests.get(f"{API_BASE}/api/predictions/{DEVICE_ID}")
        
        if response.status_code == 200:
            data = response.json()
            predictions = data.get('predictions', [])
            anomalies = data.get('anomalies', [])
            
            print(f"✅ Generated {len(predictions)} predictions")
            if predictions:
                latest = predictions[0]
                print(f"   Next prediction: {latest['value']:.1f}W at {latest['timestamp']}")
            
            if anomalies:
                print(f"⚠️  Detected {len(anomalies)} anomalies")
            else:
                print("✅ No anomalies detected")
            
            return True
        else:
            print(f"❌ Predictions failed: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Predictions error: {e}")
        return False

def main():
    print("🚀 AI Model Training Pipeline")
    print("=" * 50)
    
    # Step 1: Upload CSV data
    if not upload_csv_data():
        print("❌ Data upload failed. Exiting.")
        sys.exit(1)
    
    # Step 2: Train model
    if not train_model():
        print("❌ Model training failed. Exiting.")
        sys.exit(1)
    
    # Step 3: Test predictions
    if not test_predictions():
        print("❌ Prediction testing failed.")
        sys.exit(1)
    
    print("\n🎉 AI Model Training Complete!")
    print("The Flutter app should now show improved predictions.")

if __name__ == "__main__":
    main() 