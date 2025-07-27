#!/usr/bin/env python3
import requests
import json
from datetime import datetime, timezone
import os

# Set environment variables for Supabase
os.environ['SUPABASE_URL'] = 'http://127.0.0.1:54321'
os.environ['SUPABASE_KEY'] = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU'

# Test the AI API endpoints that the Flutter app uses
API_BASE = "http://localhost:8006"
DEVICE_ID = "d2ab803a-1742-46be-84c9-a20868642bc2"

def test_api_endpoints():
    print("=== Testing AI API Endpoints ===")
    
    # Test predictions endpoint
    try:
        response = requests.get(f"{API_BASE}/api/predictions/{DEVICE_ID}")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Predictions: {len(data.get('predictions', []))} predictions available")
            if data.get('predictions'):
                latest = data['predictions'][0]
                print(f"   Latest prediction: {latest['value']:.1f}W at {latest['timestamp']}")
        else:
            print(f"❌ Predictions failed: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"❌ Predictions error: {e}")
    
    # Test model metrics
    try:
        response = requests.get(f"{API_BASE}/api/model-metrics/{DEVICE_ID}")
        if response.status_code == 200:
            metrics = response.json()
            print(f"✅ Model Metrics: Accuracy: {metrics.get('accuracy', 0)*100:.1f}%, RMSE: {metrics.get('rmse', 0):.2f}")
        else:
            print(f"❌ Model metrics failed: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"❌ Model metrics error: {e}")

def test_supabase_data():
    print("\n=== Testing Supabase Data (Flutter Dashboard) ===")
    
    try:
        from AI_model.backend.src.database.supabase_client import SupabaseClient
        client = SupabaseClient()
        
        # Test current power (latest reading)
        readings = client.client.table('power_readings').select('power_watts, timestamp').eq('device_id', DEVICE_ID).order('timestamp', desc=True).limit(1).execute()
        if readings.data:
            latest_reading = readings.data[0]
            print(f"✅ Current Power: {latest_reading['power_watts']}W at {latest_reading['timestamp']}")
        else:
            print("❌ No current power reading found")
        
        # Test total power from all devices
        devices = client.client.table('devices').select('name, total_power').execute()
        if devices.data:
            total_power = sum(device.get('total_power', 0) or 0 for device in devices.data)
            print(f"✅ Today Total: {total_power:.6f} kWh from {len(devices.data)} devices")
        else:
            print("❌ No devices found")
        
        # Test average power (last 24h)
        from datetime import timedelta
        now = datetime.now(timezone.utc)
        yesterday = now - timedelta(hours=24)
        
        readings_24h = client.client.table('power_readings').select('power_watts').eq('device_id', DEVICE_ID).gte('timestamp', yesterday.isoformat()).lte('timestamp', now.isoformat()).execute()
        if readings_24h.data:
            powers = [r['power_watts'] for r in readings_24h.data]
            avg_power = sum(powers) / len(powers)
            print(f"✅ Average Power (24h): {avg_power:.1f}W from {len(powers)} readings")
        else:
            print("❌ No 24h power readings found")
            
    except Exception as e:
        print(f"❌ Supabase test error: {e}")

if __name__ == "__main__":
    test_api_endpoints()
    test_supabase_data()
    print("\n=== Dashboard should now show real-time data! ===") 