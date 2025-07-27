#!/usr/bin/env python3
import requests
import json
from datetime import datetime, timezone, timedelta
import random

# Configuration
API_URL = "http://localhost:8006/api/consumption/d2ab803a-1742-46be-84c9-a20868642bc2"
DEVICE_ID = "d2ab803a-1742-46be-84c9-a20868642bc2"

def add_recent_data():
    """Add some recent power consumption data"""
    
    # Generate realistic power consumption data (between 10-25 watts)
    current_time = datetime.now(timezone.utc)
    
    # Add 30 recent data points with 10-minute intervals
    for i in range(30):
        timestamp = current_time.replace(second=0, microsecond=0)
        power_watts = round(random.uniform(10.0, 25.0), 2)
        
        data = {
            "device_id": DEVICE_ID,
            "timestamp": timestamp.isoformat(),
            "consumption": power_watts
        }
        
        try:
            response = requests.post(API_URL, json=data)
            if response.status_code == 200:
                print(f"✅ Added data: {power_watts}W at {timestamp}")
            else:
                print(f"❌ Failed to add data: {response.status_code} - {response.text}")
        except Exception as e:
            print(f"❌ Error: {e}")
        
        # Move to previous 10 minutes for next data point
        current_time = current_time - timedelta(minutes=10)

if __name__ == "__main__":
    print("Adding recent power consumption data...")
    add_recent_data()
    print("Done!") 