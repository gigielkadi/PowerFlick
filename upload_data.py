import csv
import requests

API_URL = "http://localhost:8006/api/consumption/d2ab803a-1742-46be-84c9-a20868642bc2"

csv_path = "/Users/seifkhaled/Development/projects/powerflick_ copy 12/AI_model/power_readings_rows.csv"

with open(csv_path, newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        data = {
            "device_id": row["device_id"],
            "timestamp": row["timestamp"],
            "consumption": float(row["power_watts"])
        }
        response = requests.post(API_URL, json=data)
        print(f"Status: {response.status_code}, Response: {response.text}") 