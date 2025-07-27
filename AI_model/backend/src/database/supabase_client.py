from datetime import datetime
from typing import Dict, List, Optional
from supabase import create_client, Client
import os

class SupabaseClient:
    def __init__(self, url: Optional[str] = None, key: Optional[str] = None):
        self.url = url or os.getenv('SUPABASE_URL')
        self.key = key or os.getenv('SUPABASE_KEY')
        
        if not self.url or not self.key:
            raise ValueError(
                'Supabase URL and key must be provided either through '
                'constructor arguments or environment variables'
            )
            
        self.client: Client = create_client(self.url, self.key)

    def fetch_consumption_data(
        self,
        device_id: str,
        start_time: datetime,
        end_time: datetime,
    ) -> List[Dict]:
        """
        Fetch power consumption data for a device within a time range.
        """
        try:
            response = self.client.table('power_readings') \
                .select('*') \
                .eq('device_id', device_id) \
                .gte('timestamp', start_time.isoformat()) \
                .lte('timestamp', end_time.isoformat()) \
                .order('timestamp') \
                .execute()
            return response.data
        except Exception as e:
            raise Exception(f'Error fetching consumption data: {str(e)}')

    def save_consumption_data(
        self,
        device_id: str,
        timestamp: datetime,
        consumption: float,
        predicted_consumption: Optional[float] = None,
    ) -> Dict:
        """
        Save power consumption data point.
        """
        try:
            data = {
                'device_id': device_id,
                'timestamp': timestamp.isoformat(),
                'power_watts': consumption,
            }
            response = self.client.table('power_readings') \
                .upsert(data) \
                .execute()
            return response.data[0]
        except Exception as e:
            raise Exception(f'Error saving consumption data: {str(e)}')

    async def save_anomaly_alert(
        self,
        device_id: str,
        timestamp: datetime,
        value: float,
        deviation_percentage: float,
        alert_type: str,
        severity: str,
    ) -> Dict:
        """
        Save anomaly alert.
        """
        try:
            data = {
                'device_id': device_id,
                'timestamp': timestamp.isoformat(),
                'value': value,
                'deviation_percentage': deviation_percentage,
                'type': alert_type,
                'severity': severity,
            }
            
            response = await self.client.table('anomaly_alerts') \
                .upsert(data) \
                .execute()
                
            return response.data[0]
            
        except Exception as e:
            raise Exception(f'Error saving anomaly alert: {str(e)}')

    async def fetch_anomalies(
        self,
        device_id: str,
        start_time: datetime,
        end_time: datetime,
    ) -> List[Dict]:
        """
        Fetch anomaly alerts for a device within a time range.
        """
        try:
            response = await self.client.table('anomaly_alerts') \
                .select('*') \
                .eq('device_id', device_id) \
                .gte('timestamp', start_time.isoformat()) \
                .lte('timestamp', end_time.isoformat()) \
                .order('timestamp', desc=True) \
                .execute()
                
            return response.data
            
        except Exception as e:
            raise Exception(f'Error fetching anomalies: {str(e)}')

    async def save_model_metrics(
        self,
        device_id: str,
        metrics: Dict[str, float],
    ) -> Dict:
        """
        Save model performance metrics.
        """
        try:
            data = {
                'device_id': device_id,
                'timestamp': datetime.now().isoformat(),
                **metrics
            }
            
            response = await self.client.table('model_metrics') \
                .upsert(data) \
                .execute()
                
            return response.data[0]
            
        except Exception as e:
            raise Exception(f'Error saving model metrics: {str(e)}')

    async def get_latest_model_metrics(
        self,
        device_id: str,
    ) -> Optional[Dict]:
        """
        Get the most recent model metrics.
        """
        try:
            response = await self.client.table('model_metrics') \
                .select('*') \
                .eq('device_id', device_id) \
                .order('timestamp', desc=True) \
                .limit(1) \
                .execute()
                
            return response.data[0] if response.data else None
            
        except Exception as e:
            raise Exception(f'Error fetching model metrics: {str(e)}') 